#!/bin/bash
set -o pipefail

# Update pod repo to ensure we retrieve the latest version.
echo "Updating pods..."
pod repo list
pod repo add-cdn trunk "https://cdn.cocoapods.org/"
pod repo update
pod spec which Firebase

# Uncomment for testing purposes:
#GITHUB_TOKEN=your-token-here
#GITHUB_REPOSITORY=invertase/firestore-ios-sdk-frameworks

FIREBASE_GITHUB_REPOSITORY=firebase/firebase-ios-sdk
LATEST_FIREBASE_PODSPEC=$(pod spec which Firebase)
LATEST_FIREBASE_VERSION=$(python3 -c 'import json,sys; print(json.loads(sys.stdin.read())["version"])' <"$LATEST_FIREBASE_PODSPEC")
echo "LATEST_FIREBASE_VERSION=$LATEST_FIREBASE_VERSION" >> "$GITHUB_ENV"

# -------------------
#      Functions
# -------------------
# Creates a new GitHub release
#   ARGS:
#     1: Name of the release (becomes the release title on GitHub)
#     2: Markdown body of the release
#     3: Release git tag
create_github_release() {
  local response=''
  local created=''
  local release_name=$1
  local release_body=$2
  local release_tag=$3

  local body='{
	  "tag_name": "%s",
	  "target_commitish": "main",
	  "name": "%s",
	  "body": %s,
	  "draft": false,
	  "prerelease": false
	}'

  # shellcheck disable=SC2059
  body=$(printf "$body" "$release_tag" "$release_name" "$release_body")
  response=$(curl --request POST \
    --url https://api.github.com/repos/${GITHUB_REPOSITORY}/releases \
    --header "Authorization: Bearer $GITHUB_TOKEN" \
    --header 'Content-Type: application/json' \
    --data "$body" \
    -s)

  created=$(echo "$response" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('id', sys.stdin))")
  if [ "$created" != "$response" ]; then
    echo "Release created successfully!"
  else
    printf "Release failed to create; "
    printf "\n%s\n" "$body"
    printf "\n%s\n" "$response"
    exit 1
  fi
}

# Gets the JSON contents of a GitHub release
#   ARGS:
#     1: GitHub Repository
#     2: Release tag name
get_github_release_by_tag() {
  local github_repository=$1
  local release_tag=$2
  local response=''
  local release_id=''

  response=$(curl --request GET \
    --url "https://api.github.com/repos/${github_repository}/releases/tags/${release_tag}" \
    --header "Authorization: Bearer $GITHUB_TOKEN" \
    --header 'Content-Type: application/json' \
    -s)

  release_id=$(echo "$response" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('id', 'Not Found'))")
  if [ "$release_id" != "Not Found" ]; then
    echo "$response"
  else
    response_message=$(echo "$response" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('message'))")
    if [ "$response_message" != "Not Found" ]; then
      echo "Failed to query release '$release_name' -> GitHub API request failed with response: $response_message"
      echo "$response"
      exit 1
    fi
  fi
}

# -------------------
#    Main Script
# -------------------

# Ensure that the GITHUB_TOKEN env variable is defined
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Missing required GITHUB_TOKEN env variable. Set this on the workflow action or on your local environment."
  exit 1
fi

# Ensure that the GITHUB_REPOSITORY env variable is defined
if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Missing required GITHUB_REPOSITORY env variable. Set this on the workflow action or on your local environment."
  exit 1
fi

echo "The latest Firebase pod version is $LATEST_FIREBASE_VERSION, checking if a frameworks release tag exists."

# Check if the framework release already exists, exit if it does.
framework_repo_release=$(get_github_release_by_tag "$GITHUB_REPOSITORY" "$LATEST_FIREBASE_VERSION")
if [[ -n "$framework_repo_release" ]]; then
  echo "Tag for this release already exists, exiting early."
  exit 0
fi

firebase_firestore_version=$(python3 -c 'import json,sys; print(next((x for x in json.loads(sys.stdin.read())["subspecs"] if x["name"] == "Firestore"), None)["dependencies"]["FirebaseFirestore"][0])' <"$LATEST_FIREBASE_PODSPEC")
# Sanity check we actually got the subspec version value as it should look something like `~> 1.15.0`
if [[ "$firebase_firestore_version" != '~>'* ]]; then
  echo ""
  echo "Output of firebase_firestore_version:"
  echo "$firebase_firestore_version"
  echo ""
  echo "Error: could not retrieve FirebaseFirestore subspec version from the Firebase spec."
  exit 1
fi
# Remove `~> ` prefix
# shellcheck disable=SC2001
firebase_firestore_version=$(echo "$firebase_firestore_version" | sed 's/\~\> //g')

echo "Found FirebaseFirestore subspec with version '$firebase_firestore_version'"
echo "A frameworks tag for Firebase pod version $LATEST_FIREBASE_VERSION does not yet exist, creating it..."

# Get the release information from the Firebase iOS SDK repository, so we can extract the asset zip to download.
firebase_ios_repo_release=$(get_github_release_by_tag "$FIREBASE_GITHUB_REPOSITORY" "$LATEST_FIREBASE_VERSION")
if [[ -z "$firebase_ios_repo_release" ]]; then
  echo "Warning: could not find a release with the tag $LATEST_FIREBASE_VERSION on the $FIREBASE_GITHUB_REPOSITORY repository."
  # On the off-chance they tagged it slightly differently (e.g. '7.3.0' vs 'CocoaPods-7.3.0' try the other one
  firebase_ios_repo_release=$(get_github_release_by_tag "$FIREBASE_GITHUB_REPOSITORY" "CocoaPods-$LATEST_FIREBASE_VERSION")
  if [[ -z "$firebase_ios_repo_release" ]]; then
    echo "Warning: backup check for tag CocoaPods-$LATEST_FIREBASE_VERSION on the $FIREBASE_GITHUB_REPOSITORY repository also failed."

    # On the off-chance they tagged it slightly differently (e.g. 'v8.9.0' vs 'CocoaPods-8.9.0' try that
    firebase_ios_repo_release=$(get_github_release_by_tag "$FIREBASE_GITHUB_REPOSITORY" "v$LATEST_FIREBASE_VERSION")
    if [[ -z "$firebase_ios_repo_release" ]]; then
      echo "Error: backup check for tag v$LATEST_FIREBASE_VERSION on the $FIREBASE_GITHUB_REPOSITORY repository also failed."
      exit 1
    fi
  fi
fi

# Check the release actually has any assets (sometimes the don't)
if [[ "$firebase_ios_repo_release" != *".zip"* ]]; then
  echo ""
  echo ""
  echo "$firebase_ios_repo_release"
  echo ""
  echo "Error: the Firebase release above doesn't seem to have any assets :("
  exit 1
fi

firebase_release_archive=$(echo "$firebase_ios_repo_release" | python3 -c 'import json,sys; print(json.loads(sys.stdin.read())["assets"][0]["browser_download_url"])')
echo "Found archive asset, downloading from url $firebase_release_archive ..."

# Create .tmp directory to download and extract binaries from
mkdir -p .tmp

# Cleanup previous output if it exists
#rm -f .tmp/Firebase.zip
rm -rf .tmp/Firebase

# Download the zip
curl --fail --location "$firebase_release_archive" > .tmp/Firebase.zip

echo "Download successful, extracting archive..."
unzip -q .tmp/Firebase.zip 'Firebase/FirebaseFirestore/*' -d .tmp/

# Make sure xcframework exists in extracted folder
if [ ! -d ".tmp/Firebase/FirebaseFirestore/FirebaseFirestore.xcframework" ]; then
  echo ""
  echo "Contents of .tmp/:"
  ls -la .tmp/ || true
  echo ""
  echo "Contents of .tmp/Firebase:"
  ls -la .tmp/Firebase || true
  echo ""
  echo "Contents of .tmp/Firebase/FirebaseFirestore:"
  echo ""
  ls -la .tmp/Firebase/FirebaseFirestore || true
  echo "Error: archive extraction may have failed as FirebaseFirestore.xcframework output could not be found."
  exit 1
fi

echo "Archive successfully extracted, updating frameworks in repository..."
# Remove repository copy
rm -rf FirebaseFirestore
# Copy new changes from .tmp
rsync -a .tmp/Firebase/FirebaseFirestore .
# Make sure xcframework exists in repository frameworks
if [ ! -d "FirebaseFirestore/FirebaseFirestore.xcframework" ]; then
  echo "Error: updating frameworks in repository may have failed as the FirebaseFirestore.xcframework could not be found."
  exit 1
fi

rm -rf .tmp

# Update FirebaseFirestore.podspec with new version
updated_version_line="firebase_firestore_version = '$firebase_firestore_version'"
updated_podspec_contents=$(sed "1s/.*/$updated_version_line/" FirebaseFirestore.podspec)
echo "$updated_podspec_contents" >FirebaseFirestore.podspec

# Update Readme with new version
new_version_added_line="<!--NEW_VERSION_PLACEHOLDER-->¬ - [$LATEST_FIREBASE_VERSION](https:\/\/github.com\/invertase\/firestore-ios-sdk-frameworks\/releases\/tag\/$LATEST_FIREBASE_VERSION)"
updated_readme_contents=$(sed -e "s/<!--NEW_VERSION_PLACEHOLDER-->.*/$new_version_added_line/" README.md | tr '¬' '\n')
echo "$updated_readme_contents" >README.md

# Commit changes and make a release
git add .
git commit -m "release: $LATEST_FIREBASE_VERSION"
git tag -a "$LATEST_FIREBASE_VERSION" -m "$LATEST_FIREBASE_VERSION"
git push origin main --follow-tags
create_github_release "$LATEST_FIREBASE_VERSION" "\"[View Firebase iOS SDK Release](https://github.com/firebase/firebase-ios-sdk/releases/tag/$LATEST_FIREBASE_VERSION)\"" "$LATEST_FIREBASE_VERSION"

echo ""
echo "Release $LATEST_FIREBASE_VERSION complete."
