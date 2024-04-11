#!/bin/bash
set -o pipefail

# THE JSON path for outputs
json_file_write_path=$1

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

# Capture the line with the version range for abseil
version_line=$(echo "$package_swift" | grep -o '".*\.\.<.*"')


# Check if the version line was captured
if [[ -z $version_line ]]; then
  echo "Failed to capture the version line."
  exit 1
fi

# Extract the first part of the version
firebase_firestore_abseil_version=$(echo "$version_line" | awk -F\" '{print $2}' | head -1)


# Check if the versions were extracted
if [[ -z $firebase_firestore_abseil_version ]]; then
  echo "Failed to extract the Firebase Firestore Abseil version."
  exit 1
fi

if [ -z "$firebase_firestore_version" ]; then
  echo "Failed to extract Firebase Firestore version from podspec."
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

# Write to a temporary JSON file for reading in the next step
# Ensure the tmp directory exists
mkdir -p ./tmp


# Output the variables in JSON format to a local temporary file. filename is passed as first argument.
cat <<EOF > $json_file_write_path
{
  "firebase_firestore_version": "$firebase_firestore_version",
  "firebase_firestore_grpc_version": "$firebase_firestore_grpc_version",
  "firebase_firestore_leveldb_version": "$firebase_firestore_leveldb_version",
  "firebase_firestore_nanopb_version_min": "$firebase_firestore_nanopb_version_min",
  "firebase_firestore_nanopb_version_max": "$firebase_firestore_nanopb_version_max",
  "firebase_firestore_abseil_version": "$firebase_firestore_abseil_version"
}
EOF

