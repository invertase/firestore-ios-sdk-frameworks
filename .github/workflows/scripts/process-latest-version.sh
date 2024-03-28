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
pod repo add cocoapods "https://github.com/CocoaPods/Specs.git"
pod repo update
pod spec which FirebaseFirestoreInternal

PODSPEC_FILE=$(pod spec which FirebaseFirestoreInternal)

# Extract Firebase Firestore version
firebase_firestore_version=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["version"])')

# Extract gRPC version
firebase_firestore_grpc_version=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["gRPC-C++"][0].replace("~> ", ""))')
# If the gRPC version is 1.62.0, set it to 1.62.1
# Since the tag is missing for 1.62.0.
if [ "$firebase_firestore_grpc_version" = "1.62.0" ]; then
  echo "Overriding gRPC version to 1.62.1"
  firebase_firestore_grpc_version="1.62.1"
fi

# Extract leveldb version
firebase_firestore_leveldb_version=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["leveldb-library"][0])')

# Extract nanopb minimum version
firebase_firestore_nanopb_version_min=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["nanopb"][0])')

# Extract nanopb maximum version
firebase_firestore_nanopb_version_max=$(python3 -c 'import json; data = json.load(open("'"$PODSPEC_FILE"'")); print(data["dependencies"]["nanopb"][1])')

# URL of the grpc binary Package.swift file
grpc_binary_swift_url="https://raw.githubusercontent.com/google/grpc-binary/$firebase_firestore_grpc_version/Package.swift"

# Fetch the Package.swift file
echo "Fetching Package.swift file from $grpc_binary_swift_url"
package_swift=$(curl -s $grpc_binary_swift_url)

# Check if the fetch was successful
if [[ -z $package_swift ]]; then
  echo "Failed to fetch the Package.swift grpc binary file."
  exit 1
fi

# GRPC CORE BINARY UPDATE
: <<'END_COMMENT'
- Captures the version from the grpc binary Package.swift file.
- Extracts the URL of the Firebase Firestore GRPC core package from the grpc Package.swift file for source in FirebaseFirestoreGRPCCoreBinary.podspec
- Extracts the path and resource process path of the PrivacyInfo.xcprivacy file from the grpc binary Package.swift file and writes the content to Resources/grpc/PrivacyInfo.xcprivacy.
END_COMMENT

firebase_firestore_grpc_version_url=$(echo "$package_swift" | grep -A1 "name: \"grpc\"" | grep "url" | sed -E 's/.*url: "(.*)",.*/\1/')

# Extract the section for the grpcWrapper target
grpc_wrapper_section=$(echo "$package_swift" | awk '/grpcWrapper/,/}/' | grep -v 'opensslWrapper\|grpcppWrapper')

# Extract the path value for grpcWrapper
grpc_wrapper_path=$(echo "$grpc_wrapper_section" | grep -m1 'path: ' | sed -E 's/.*path: "([^"]*)".*/\1/')

# Extract the resource process path for grpcWrapper
grpc_wrapper_resource_process_path=$(echo "$grpc_wrapper_section" | grep -m1 'process(' | sed -E 's/.*process\("([^"]*)"\).*/\1/')

grpc_privacy_resource_url="https://raw.githubusercontent.com/google/grpc-binary/1.62.1/$grpc_wrapper_path/$grpc_wrapper_resource_process_path"

# Ensure the directory "Resources/grpc" exists
mkdir -p Resources/grpc

# Fetch the content
grpc_privacy_content=$(curl -s "$grpc_privacy_resource_url")

# Check if the grpc_privacy_content is an XML file with <plist></plist>
if [[ $grpc_privacy_content == *"?xml"* ]] && [[ $grpc_privacy_content == *"</plist>"* ]]; then
    # Write the grpc_privacy_content into the file "Resources/grpc/PrivacyInfo.xcprivacy"
    echo "$grpc_privacy_content" > "Resources/grpc/PrivacyInfo.xcprivacy"
    echo "Privacy resource successfully written to Resources/grpc/PrivacyInfo.xcprivacy"
else
    echo "Failed to write the privacy resource for grpc: Content is not a valid XML plist file."
    exit 1
fi

# GRPCPP (GRPC CPP) BINARY UPDATE
: <<'END_COMMENT'
- Captures the version from the grpc binary Package.swift file.
- Extracts the URL of the Firebase Firestore GRPC CPP package from the grpc Package.swift file for source in FirebaseFirestoreGRPCCPPBinary.podspec
- Extracts the path and resource process path of the PrivacyInfo.xcprivacy file from the grpc binary Package.swift file and writes the content to Resources/grpcpp/PrivacyInfo.xcprivacy.
END_COMMENT

# Extract the URL of the grpcpp zip for the podspec
firebase_firestore_grpc_ccp_version_url=$(echo "$package_swift" | grep -A1 "name: \"grpcpp\"" | grep "url" | sed -E 's/.*url: "(.*)",.*/\1/')

# Extract the section for the grpcppWrapper target
grpcpp_wrapper_section=$(echo "$package_swift" | sed -n '/name: "grpcppWrapper"/,/^ *},/p' | grep -v 'name: "grpcWrapper"\|name: "opensslWrapper"')

# Extract the path value for grpcppWrapper
grpcpp_wrapper_path=$(echo "$grpcpp_wrapper_section" | grep -m1 'path: ' | sed -E 's/.*path: "([^"]*)".*/\1/')

# Extract the resource process path for grpcppWrapper
grpcpp_wrapper_resource_process_path=$(echo "$grpcpp_wrapper_section" | grep -m1 'process(' | sed -E 's/.*process\("([^"]*)"\).*/\1/')


grpcpp_privacy_resource_url="https://raw.githubusercontent.com/google/grpc-binary/1.62.1/$grpcpp_wrapper_path/$grpcpp_wrapper_resource_process_path"

# Ensure the directory "Resources/grpcpp" exists
mkdir -p Resources/grpcpp

# Fetch the content
grpcpp_privacy_content=$(curl -s "$grpcpp_privacy_resource_url")

# Check if the grpcpp_privacy_content is an XML file with <plist></plist>
if [[ $grpcpp_privacy_content == *"?xml"* ]] && [[ $grpcpp_privacy_content == *"</plist>"* ]]; then
    # Write the grpcpp_privacy_content into the file "Resources/grpcpp/PrivacyInfo.xcprivacy"
    echo "$grpcpp_privacy_content" > "Resources/grpcpp/PrivacyInfo.xcprivacy"
    echo "Privacy resource successfully written to Resources/grpcpp/PrivacyInfo.xcprivacy"
else
    echo "Failed to write the privacy resource for grpcpp: Content is not a valid XML plist file."
    exit 1
fi

# ABSEIL BINARY UPDATE
: <<'END_COMMENT'
- Captures the version range of the Firebase Firestore Abseil package from the grpc binary Package.swift file.
- Takes the first part of the version range and uses it to fetch the Package.swift file of the abseil-cpp-binary repository.
- Extracts the URL of the Firebase Firestore Abseil package from the abseil-cpp-binary Package.swift file.
- Extracts the path and resource process path of the PrivacyInfo.xcprivacy file from the abseil-cpp-binary Package.swift file and writes the content to Resources/abseil/PrivacyInfo.xcprivacy.
END_COMMENT

# Capture the line with the version range
version_line=$(echo "$package_swift" | grep -o '".*\.\.<.*"')


# Check if the version line was captured
if [[ -z $version_line ]]; then
  echo "Failed to capture the version line."
  exit 1
fi

# Extract the first part of the version
firebase_firestore_abseil_version=$(echo "$version_line" | awk -F\" '{print $2}' | head -1)


# Check if the version was extracted
if [[ -z $firebase_firestore_abseil_version ]]; then
  echo "Failed to extract the Firebase Firestore Abseil version."
  exit 1
fi

# URL of the abseil cpp binary Package.swift file
abseil_cpp_binary_url="https://raw.githubusercontent.com/google/abseil-cpp-binary/$firebase_firestore_abseil_version/Package.swift"

# Fetch the Package.swift file
echo "Fetching Package.swift file from $abseil_cpp_binary_url"
abseil_cpp_binary_package_swift=$(curl -s $abseil_cpp_binary_url)

# Check if the fetch was successful
if [[ -z $abseil_cpp_binary_package_swift ]]; then
  echo "Failed to fetch the Package.swift abseil cpp binary file."
  exit 1
fi

# Extract the abseil URL
firebase_firestore_abseil_url=$(echo "$abseil_cpp_binary_package_swift" | grep -m1 "url: \"" | sed -E 's|.*url: "([^"]+)".*|\1|')

# Check if the URL was extracted
if [[ -z $firebase_firestore_abseil_url ]]; then
  echo "Failed to extract the Firebase Firestore Abseil URL."
  exit 1
fi

# Extract the path ("absl-Wrapper")
path=$(echo "$abseil_cpp_binary_package_swift" | grep -o 'path: "[^"]*"' | sed -E 's/path: "([^"]*)"/\1/' | head -1)

# Extract the resource process path ("Resources/PrivacyInfo.xcprivacy")
resource_process_path=$(echo "$abseil_cpp_binary_package_swift" | grep -o 'process("[^"]*")' | sed -E 's/process\("([^"]*)"\)/\1/' | head -1)

abseil_privacy_resource_url="https://raw.githubusercontent.com/google/abseil-cpp-binary/$firebase_firestore_abseil_version/$path/$resource_process_path"

# Ensure the directory "Resources/abseil" exists
mkdir -p Resources/abseil

# Fetch the content
abseil_privacy_content=$(curl -s "$abseil_privacy_resource_url")

# Check if the abseil_privacy_content is an XML file with <plist></plist>
if [[ $abseil_privacy_content == *"?xml"* ]] && [[ $abseil_privacy_content == *"</plist>"* ]]; then
    # Write the abseil_privacy_content into the file "Resources/abseil/PrivacyInfo.xcprivacy"
    echo "$abseil_privacy_content" > "Resources/abseil/PrivacyInfo.xcprivacy"
    echo "Privacy resource successfully written to Resources/abseil/PrivacyInfo.xcprivacy"
else
    echo "Failed to write the privacy resource: Content is not a valid XML plist file."
    exit 1
fi

# OPENSSL BINARY UPDATE (Previously BoringSSL-GRPC)
: <<'END_COMMENT'
- Captures the version from the grpc binary Package.swift file.
- Extracts the URL of the Firebase Firestore Open SSL package from the grpc Package.swift file for source in FirebaseFirestoreGRPCBoringSSLBinary.podspec
- Extracts the path and resource process path of the PrivacyInfo.xcprivacy file from the grpc binary Package.swift file and writes the content to Resources/open_ssl/PrivacyInfo.xcprivacy.
END_COMMENT

# Extract the BoringSSL-GRPC version from the grpc binary target URL
firebase_firestore_grpc_boringssl_version=$(echo "$package_swift" | grep -m1 "url: \"https://dl.google.com/firebase/ios/bin/grpc/" | sed -E 's|.*/grpc/([0-9]+\.[0-9]+\.[0-9]+)/.*|\1|')

# Check if the version was extracted
if [[ -z $firebase_firestore_grpc_boringssl_version ]]; then
  echo "Failed to extract BoringSSL-GRPC version."
  exit 1
fi

# Extract the URL for openssl_grpc
firebase_firestore_grpc_boringssl_url=$(echo "$package_swift" | grep -A1 "name: \"openssl_grpc\"" | grep "url" | sed -E 's/.*url: "(.*)",.*/\1/')

if [[ -z $firebase_firestore_grpc_boringssl_url ]]; then
  echo "Failed to extract the BoringSSL-GRPC URL."
  exit 1
fi

# Use URL of the gRPC binary Package.swift file to get the privacy resource for open_ssl
# Extract the section for the opensslWrapper target
openssl_wrapper_section=$(echo "$package_swift" | awk '/opensslWrapper/,/}/' | grep -v 'grpcWrapper\|grpcppWrapper')

# Extract the path value for opensslWrapper
openssl_wrapper_path=$(echo "$openssl_wrapper_section" | grep -m1 'path: ' | sed -E 's/.*path: "([^"]*)".*/\1/')

# Extract the resource process path for opensslWrapper
openssl_wrapper_resource_process_path=$(echo "$openssl_wrapper_section" | grep -m1 'process(' | sed -E 's/.*process\("([^"]*)"\).*/\1/')

open_ssl_privacy_resource_url="https://raw.githubusercontent.com/google/grpc-binary/1.62.1/$openssl_wrapper_path/$openssl_wrapper_resource_process_path"

# Ensure the directory "Resources/open_ssl" exists
mkdir -p Resources/open_ssl

# Fetch the content
open_ssl_privacy_content=$(curl -s "$open_ssl_privacy_resource_url")

# Check if the open_ssl_privacy_content is an XML file with <plist></plist>
if [[ $open_ssl_privacy_content == *"?xml"* ]] && [[ $open_ssl_privacy_content == *"</plist>"* ]]; then
    # Write the open_ssl_privacy_content into the file "Resources/open_ssl/PrivacyInfo.xcprivacy"
    echo "$open_ssl_privacy_content" > "Resources/open_ssl/PrivacyInfo.xcprivacy"
    echo "Privacy resource successfully written to Resources/open_ssl/PrivacyInfo.xcprivacy"
else
    echo "Failed to write the privacy resource open_ssl: Content is not a valid XML plist file."
    exit 1
fi


# Output the extracted values
echo "firebase_firestore_version = '$firebase_firestore_version'"
echo "firebase_firestore_abseil_url = '$firebase_firestore_abseil_url'"
echo "firebase_firestore_abseil_version = '$firebase_firestore_abseil_version'"
echo "firebase_firestore_grpc_version = '$firebase_firestore_grpc_version'"
echo "firebase_firestore_leveldb_version = '$firebase_firestore_leveldb_version'"
echo "firebase_firestore_nanopb_version_min = '$firebase_firestore_nanopb_version_min'"
echo "firebase_firestore_nanopb_version_max = '$firebase_firestore_nanopb_version_max'"
echo "firebase_firestore_boringssl_version = '$firebase_firestore_grpc_boringssl_version'"
echo "firebase_firestore_grpc_version_url = '$firebase_firestore_grpc_version_url'"
echo "firebase_firestore_grpc_ccp_version_url = '$firebase_firestore_grpc_ccp_version_url'"
echo "firebase_firestore_grpc_boringssl_url = '$firebase_firestore_grpc_boringssl_url'"


# Check if the grpc version URL was extracted
if [[ -z $firebase_firestore_grpc_version_url ]]; then
  echo "Failed to extract the gRPC version URL."
  exit 1
fi

# Check if the grpcpp version URL was extracted
if [[ -z $firebase_firestore_grpc_ccp_version_url ]]; then
  echo "Failed to extract the gRPC CPP version URL."
  exit 1
fi

# Check if the BoringSSL-GRPC URL was extracted
if [[ -z $firebase_firestore_grpc_boringssl_url ]]; then
  echo "Failed to extract the BoringSSL-GRPC URL."
  exit 1
fi

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

if [ $(git tag -l "$firebase_firestore_version") ]; then
  echo "Tag $firebase_firestore_version already exists, skipping release."
  exit 0
fi

for file in *.podspec; do
  sed -i '' "s|firebase_firestore_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_version='$firebase_firestore_version'|" "$file"
  sed -i '' "s|firebase_firestore_abseil_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_abseil_url='$firebase_firestore_abseil_url'|" "$file"
  sed -i '' "s|firebase_firestore_abseil_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_abseil_version='$firebase_firestore_abseil_version'|" "$file"
  sed -i '' "s|firebase_firestore_grpc_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_version='$firebase_firestore_grpc_version'|" "$file"
  sed -i '' "s|firebase_firestore_grpc_version_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_version_url='$firebase_firestore_grpc_version_url'|" "$file"
  sed -i '' "s|firebase_firestore_grpc_ccp_version_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_ccp_version_url='$firebase_firestore_grpc_ccp_version_url'|" "$file"
  sed -i '' "s|firebase_firestore_grpc_boringssl_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_boringssl_url='$firebase_firestore_grpc_boringssl_url'|" "$file"
  sed -i '' "s|firebase_firestore_leveldb_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_leveldb_version='$firebase_firestore_leveldb_version'|" "$file"
  sed -i '' "s|firebase_firestore_nanopb_version_min[[:space:]]*=[[:space:]]*.*|firebase_firestore_nanopb_version_min='$firebase_firestore_nanopb_version_min'|" "$file"
  sed -i '' "s|firebase_firestore_nanopb_version_max[[:space:]]*=[[:space:]]*.*|firebase_firestore_nanopb_version_max='$firebase_firestore_nanopb_version_max'|" "$file"
done

new_version_added_line="<!--NEW_VERSION_PLACEHOLDER-->¬ - [$firebase_firestore_version](https:\/\/github.com\/invertase\/firestore-ios-sdk-frameworks\/releases\/tag\/$firebase_firestore_version)"
updated_readme_contents=$(sed -e "s/<!--NEW_VERSION_PLACEHOLDER-->.*/$new_version_added_line/" README.md | tr '¬' '\n')
echo "$updated_readme_contents" >README.md

git add .
git commit -m "release: $firebase_firestore_version"
git tag -a "$firebase_firestore_version" -m "$firebase_firestore_version"
git push origin main --follow-tags
create_github_release "$firebase_firestore_version" "\"[View Firebase iOS SDK Release](https://github.com/firebase/firebase-ios-sdk/releases/tag/$firebase_firestore_version)\"" "$firebase_firestore_version"

pod spec which FirebaseFirestoreGRPCBoringSSLBinary --version="$firebase_firestore_grpc_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreGRPCBoringSSLBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  pod repo update cocoapods
else
  echo "FirebaseFirestoreGRPCBoringSSLBinary already exists"
fi

pod spec which FirebaseFirestoreGRPCCoreBinary --version="$firebase_firestore_grpc_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreGRPCCoreBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  pod repo update cocoapods
else
  echo "FirebaseFirestoreGRPCCoreBinary already exists"
fi

pod spec which FirebaseFirestoreGRPCCPPBinary --version="$firebase_firestore_grpc_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreGRPCCPPBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  pod repo update cocoapods
else
  echo "FirebaseFirestoreGRPCCPPBinary already exists"
fi

pod spec which FirebaseFirestoreAbseilBinary --version="$firebase_firestore_abseil_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreAbseilBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  pod repo update cocoapods
else
  echo "FirebaseFirestoreAbseilBinary already exists"
fi

pod spec which FirebaseFirestoreInternalBinary --version="$firebase_firestore_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreInternalBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
  pod repo update cocoapods
else
  echo "FirebaseFirestoreInternalBinary already exists"
fi

pod spec which FirebaseFirestoreBinary --version="$firebase_firestore_version"
exit_code=$?
if [ $exit_code -eq 1 ]; then
  pod trunk push FirebaseFirestoreBinary.podspec --allow-warnings --skip-tests --skip-import-validation --synchronous
else
  echo "FirebaseFirestoreBinary already exists"
fi

echo ""
echo "Release $LATEST_FIREBASE_VERSION complete."
