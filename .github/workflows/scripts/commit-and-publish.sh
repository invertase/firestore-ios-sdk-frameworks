#!/bin/bash
set -o pipefail

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

if [ $(git tag -l "$firebase_firestore_version") ]; then
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

pod repo add cocoapods "https://github.com/CocoaPods/Specs.git"

pod repo update
echo "Running 'pod spec which FirebaseFirestoreGRPCBoringSSLBinary --version=$firebase_firestore_grpc_version'"
pod spec which FirebaseFirestoreGRPCBoringSSLBinary --version="$firebase_firestore_grpc_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreGRPCBoringSSLBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  exit_code=$?
  sleep 5m
  pod repo update cocoapods
else
  echo "FirebaseFirestoreGRPCBoringSSLBinary already exists"
fi
if [ $exit_code -ne 0 ]; then
  echo "Failed to push FirebaseFirestoreGRPCBoringSSLBinary"
  exit 1
fi

pod repo update
echo "Running 'pod spec which FirebaseFirestoreAbseilBinary --version=$firebase_firestore_abseil_version'"
pod spec which FirebaseFirestoreAbseilBinary --version="$firebase_firestore_abseil_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreAbseilBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  exit_code=$?
  sleep 5m
  pod repo update cocoapods
else
  echo "FirebaseFirestoreAbseilBinary already exists"
fi
if [ $exit_code -ne 0 ]; then
  echo "Failed to push FirebaseFirestoreAbseilBinary"
  exit 1
fi

pod repo update
echo "Running 'pod spec which FirebaseFirestoreGRPCCoreBinary --version=$firebase_firestore_grpc_version'"
pod spec which FirebaseFirestoreGRPCCoreBinary --version="$firebase_firestore_grpc_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreGRPCCoreBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  exit_code=$?
  sleep 5m
  pod repo update cocoapods
else
  echo "FirebaseFirestoreGRPCCoreBinary already exists"
fi
if [ $exit_code -ne 0 ]; then
  echo "Failed to push FirebaseFirestoreGRPCCoreBinary"
  exit 1
fi

pod repo update
echo "Running 'pod spec which FirebaseFirestoreGRPCCPPBinary --version=$firebase_firestore_grpc_version'"
pod spec which FirebaseFirestoreGRPCCPPBinary --version="$firebase_firestore_grpc_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreGRPCCPPBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  exit_code=$?
  sleep 5m
  pod repo update cocoapods
else
  echo "FirebaseFirestoreGRPCCPPBinary already exists"
fi
if [ $exit_code -ne 0 ]; then
  echo "Failed to push FirebaseFirestoreGRPCCPPBinary"
  exit 1
fi

pod repo update
echo "Running 'pod spec which FirebaseFirestoreInternalBinary --version=$firebase_firestore_version'"
pod spec which FirebaseFirestoreInternalBinary --version="$firebase_firestore_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreInternalBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  exit_code=$?
  sleep 5m
  pod repo update cocoapods
else
  echo "Force delete then re-push FirebaseFirestoreInternalBinary"
  pod trunk delete FirebaseFirestoreInternalBinary "$firebase_firestore_version"
  pod trunk push FirebaseFirestoreInternalBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  exit_code=$?
  sleep 5m
  pod repo update cocoapods
fi
if [ $exit_code -ne 0 ]; then
  echo "Failed to push FirebaseFirestoreInternalBinary"
  exit 1
fi

pod repo update
echo "Running 'pod spec which FirebaseFirestoreBinary --version=$firebase_firestore_version'"
pod spec which FirebaseFirestoreBinary --version="$firebase_firestore_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  exit_code=$?
else
  echo "FirebaseFirestoreBinary already exists"
fi
if [ $exit_code -ne 0 ]; then
  echo "Failed to push FirebaseFirestoreBinary"
  exit 1
fi



echo ""
echo "Release $LATEST_FIREBASE_VERSION complete."