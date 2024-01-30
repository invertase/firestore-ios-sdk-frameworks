#!/bin/bash
set -o pipefail

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

# Update pod repo to ensure we retrieve the latest version.
echo "Updating pods..."
pod repo list
pod repo add-cdn trunk "https://cdn.cocoapods.org/"
pod repo update
pod spec which FirebaseFirestoreInternal

PODSPEC_FILE=$(pod spec which FirebaseFirestoreInternal)

# Extract Firebase Firestore version
firebase_firestore_version=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["version"])')

# Extract the Firebase Firestore Abseil version and pad it with two extra zeros (for some reason)
firebase_firestore_abseil_version=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); version = data["dependencies"]["abseil/algorithm"][0].replace("~> ", ""); parts = version.split("."); print(parts[0] + "." + parts[1] + "00." + parts[2])')

# Extract gRPC version
firebase_firestore_grpc_version=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["gRPC-C++"][0].replace("~> ", ""))')

# Extract leveldb version
firebase_firestore_leveldb_version=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["leveldb-library"][0])')

# Extract nanopb minimum version
firebase_firestore_nanopb_version_min=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["nanopb"][0])')

# Extract nanopb maximum version
firebase_firestore_nanopb_version_max=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["nanopb"][1])')

# URL of the Package.swift file
boringssl_url="https://raw.githubusercontent.com/google/grpc-binary/$firebase_firestore_grpc_version/Package.swift"

# Fetch the Package.swift file
package_swift=$(curl -s $boringssl_url)

# Check if the fetch was successful
if [[ -z $package_swift ]]; then
  echo "Failed to fetch the Package.swift file."
  exit 1
fi

# Extract the BoringSSL-GRPC version
firebase_firestore_grpc_boringssl_version=$(echo "$package_swift" | grep -A1 "name: \"BoringSSL-GRPC\"" | grep "url" | sed -E 's/.*grpc\/([0-9]+\.[0-9]+\.[0-9]+)\/BoringSSL-GRPC\.zip.*/\1/')

# Check if the version was extracted
if [[ -z $firebase_firestore_grpc_boringssl_version ]]; then
  echo "Failed to extract BoringSSL-GRPC version."
  exit 1
fi

# Output the extracted values
echo "firebase_firestore_version = '$firebase_firestore_version'"
echo "firebase_firestore_abseil_version = '$firebase_firestore_abseil_version'"
echo "firebase_firestore_grpc_version = '$firebase_firestore_grpc_version'"
echo "firebase_firestore_leveldb_version = '$firebase_firestore_leveldb_version'"
echo "firebase_firestore_nanopb_version_min = '$firebase_firestore_nanopb_version_min'"
echo "firebase_firestore_nanopb_version_max = '$firebase_firestore_nanopb_version_max'"
echo "firebase_firestore_boringssl_version = '$firebase_firestore_boringssl_version'"
echo "firebase_firestore_boringssl_version = '$firebase_firestore_grpc_boringssl_version'"

if [ -z "$firebase_firestore_version" ]; then
  echo "Failed to extract Firebase Firestore version from podspec."
  exit 1
fi
if [ -z "$firebase_firestore_abseil_version" ]; then
  echo "Failed to extract Firebase Firestore Abseil version from podspec."
  exit 1
fi
if [ -z "$firebase_firestore_grpc_version" ]; then
  echo "Failed to extract Firebase Firestore gRPC version from podspec."
  exit 1
fi
if [ -z "$firebase_firestore_leveldb_version" ]; then
  echo "Failed to extract Firebase Firestore leveldb version from podspec."
  exit 1
fi
if [ -z "$firebase_firestore_nanopb_version_min" ]; then
  echo "Failed to extract Firebase Firestore nanopb minimum version from podspec."
  exit 1
fi
if [ -z "$firebase_firestore_nanopb_version_max" ]; then
  echo "Failed to extract Firebase Firestore nanopb maximum version from podspec."
  exit 1
fi

if git rev-parse "$firebase_firestore_version" >/dev/null 2>&1; then
  echo "Tag $firebase_firestore_version already exists, skipping release."
else
  for file in *.podspec; do
    sed -i '' "s/^firebase_firestore_version = .*/firebase_firestore_version = '$firebase_firestore_version'/" "$file"
    sed -i '' "s/^firebase_firestore_abseil_version = .*/firebase_firestore_abseil_version = '$firebase_firestore_abseil_version'/" "$file"
    sed -i '' "s/^firebase_firestore_grpc_version = .*/firebase_firestore_grpc_version = '$firebase_firestore_grpc_version'/" "$file"
    sed -i '' "s/^firebase_firestore_grpc_boringssl_version = .*/firebase_firestore_grpc_boringssl_version = '$firebase_firestore_grpc_boringssl_version'/" "$file"
    sed -i '' "s/^firebase_firestore_leveldb_version = .*/firebase_firestore_leveldb_version = '$firebase_firestore_leveldb_version'/" "$file"
    sed -i '' "s/^firebase_firestore_nanopb_version_min = .*/firebase_firestore_nanopb_version_min = '$firebase_firestore_nanopb_version_min'/" "$file"
    sed -i '' "s/^firebase_firestore_nanopb_version_max = .*/firebase_firestore_nanopb_version_max = '$firebase_firestore_nanopb_version_max'/" "$file"
  done
  new_version_added_line="<!--NEW_VERSION_PLACEHOLDER-->¬ - [$firebase_firestore_version](https:\/\/github.com\/invertase\/firestore-ios-sdk-frameworks\/releases\/tag\/$LATEST_FIREBASE_VERSION)"
  updated_readme_contents=$(sed -e "s/<!--NEW_VERSION_PLACEHOLDER-->.*/$new_version_added_line/" README.md | tr '¬' '\n')
  echo "$updated_readme_contents" >README.md

  git add .
  git commit -m "release: $firebase_firestore_version"
  git tag -a "$firebase_firestore_version" -m "$firebase_firestore_version"
  git push origin main --follow-tags
  create_github_release "$firebase_firestore_version" "\"[View Firebase iOS SDK Release](https://github.com/firebase/firebase-ios-sdk/releases/tag/$firebase_firestore_version)\"" "$firebase_firestore_version"

  for file in *.podspec; do
    if [ "$file" != "FirebaseFirestore.podspec" ]; then
      echo "Pushing $file to trunk..."
      pod trunk push "$file" --synchronous --allow-warnings --skip-tests
    fi
  done

  echo ""
  echo "Release $LATEST_FIREBASE_VERSION complete."
fi
