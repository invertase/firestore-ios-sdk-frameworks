#!/bin/bash
set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=release-lib.sh
source "$SCRIPT_DIR/release-lib.sh"

firebase_firestore_version=$1
firebase_firestore_grpc_version=$2
firebase_firestore_abseil_version=$3

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

if [ -n "$(git tag -l "$firebase_firestore_version")" ]; then
  echo "Tag $firebase_firestore_version already exists, skipping tagging."
else
  # GIT COMMIT, PUSH & TAG
  new_version_added_line="<!--NEW_VERSION_PLACEHOLDER-->¬ - [$firebase_firestore_version](https:\/\/github.com\/invertase\/firestore-ios-sdk-frameworks\/releases\/tag\/$firebase_firestore_version)"
  updated_readme_contents=$(sed -e "s/<!--NEW_VERSION_PLACEHOLDER-->.*/$new_version_added_line/" README.md | tr '¬' '\n')
  echo "$updated_readme_contents" >README.md

  git add .
  git commit -m "release: $firebase_firestore_version"
  git tag -a "$firebase_firestore_version" -m "$firebase_firestore_version"
  git push origin main --follow-tags
  create_github_release "$firebase_firestore_version" "\"[View Firebase iOS SDK Release](https://github.com/firebase/firebase-ios-sdk/releases/tag/$firebase_firestore_version)\"" "$firebase_firestore_version"
fi

# PUSH THE PODSPECS TO COCOAPODS
push_pod_if_missing FirebaseFirestoreGRPCBoringSSLBinary "$firebase_firestore_grpc_version" FirebaseFirestoreGRPCBoringSSLBinary.podspec || exit 1
push_pod_if_missing FirebaseFirestoreAbseilBinary "$firebase_firestore_abseil_version" FirebaseFirestoreAbseilBinary.podspec || exit 1
push_pod_if_missing FirebaseFirestoreGRPCCoreBinary "$firebase_firestore_grpc_version" FirebaseFirestoreGRPCCoreBinary.podspec || exit 1
push_pod_if_missing FirebaseFirestoreGRPCCPPBinary "$firebase_firestore_grpc_version" FirebaseFirestoreGRPCCPPBinary.podspec || exit 1
push_pod_if_missing FirebaseFirestoreInternalBinary "$firebase_firestore_version" FirebaseFirestoreInternalBinary.podspec || exit 1
push_pod_if_missing FirebaseFirestoreBinary "$firebase_firestore_version" FirebaseFirestoreBinary.podspec || exit 1

echo ""
echo "Release $firebase_firestore_version complete."
