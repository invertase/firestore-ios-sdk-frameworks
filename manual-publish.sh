#!/bin/bash
set -o pipefail


# ------------------------------------------------------
#  This script should only be used in case of emergency
# ------------------------------------------------------
# Update pod repo to ensure we retrieve the latest version.
echo "Updating pods..."
pod repo list
pod repo add cocoapods "https://github.com/CocoaPods/Specs.git"
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
for file in *.podspec; do
  sed -i '' "s/^firebase_firestore_version = .*/firebase_firestore_version = '$firebase_firestore_version'/" "$file"
  sed -i '' "s/^firebase_firestore_abseil_version = .*/firebase_firestore_abseil_version = '$firebase_firestore_abseil_version'/" "$file"
  sed -i '' "s/^firebase_firestore_grpc_version = .*/firebase_firestore_grpc_version = '$firebase_firestore_grpc_version'/" "$file"
  sed -i '' "s/^firebase_firestore_grpc_boringssl_version = .*/firebase_firestore_grpc_boringssl_version = '$firebase_firestore_grpc_boringssl_version'/" "$file"
  sed -i '' "s/^firebase_firestore_leveldb_version = .*/firebase_firestore_leveldb_version = '$firebase_firestore_leveldb_version'/" "$file"
  sed -i '' "s/^firebase_firestore_nanopb_version_min = .*/firebase_firestore_nanopb_version_min = '$firebase_firestore_nanopb_version_min'/" "$file"
  sed -i '' "s/^firebase_firestore_nanopb_version_max = .*/firebase_firestore_nanopb_version_max = '$firebase_firestore_nanopb_version_max'/" "$file"
done

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
  pod repo update cocoapods
else
  echo "FirebaseFirestoreBinary already exists"
fi
