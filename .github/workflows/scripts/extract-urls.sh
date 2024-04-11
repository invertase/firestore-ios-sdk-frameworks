#!/bin/bash
set -o pipefail

json_file_write_path=$1

firebase_firestore_grpc_version=$2
firebase_firestore_abseil_version=$3
firebase_firestore_version=$4

# URL of the grpc binary Package.swift file
grpc_binary_swift_url="https://raw.githubusercontent.com/google/grpc-binary/$firebase_firestore_grpc_version/Package.swift"

# URL of the Firebase Package.swift file
firebase_package_swift_url="https://raw.githubusercontent.com/firebase/firebase-ios-sdk/$firebase_firestore_version/Package.swift"



# Fetch the Package.swift file
firestore_package_swift=$(curl -s "$firebase_package_swift_url")

# Check if the fetch was successful
if [[ -z $firestore_package_swift ]]; then
  echo "Failed to fetch the Package.swift file for firebase firestore."
  exit 1
fi

# Extract the URL for FirebaseFirestoreInternal
firebase_firestore_internal_url=$(echo "$firestore_package_swift" | grep -Eo 'url: "https://dl.google.com/firebase/ios/bin/firestore/[0-9.]+/rc[0-9]+/FirebaseFirestoreInternal.zip"' | grep -Eo 'https://[^"]+')


# Fetch the Package.swift file
echo "Fetching Package.swift file from $grpc_binary_swift_url"
package_swift=$(curl -s $grpc_binary_swift_url)


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

# Extract the grpc URL
firebase_firestore_grpc_version_url=$(echo "$package_swift" | grep -A1 "name: \"grpc\"" | grep "url" | sed -E 's/.*url: "(.*)",.*/\1/')

# Extract the URL for openssl_grpc
firebase_firestore_grpc_boringssl_url=$(echo "$package_swift" | grep -A1 "name: \"openssl_grpc\"" | grep "url" | sed -E 's/.*url: "(.*)",.*/\1/')

# Extract the URL of the grpcpp zip for the podspec
firebase_firestore_grpc_ccp_version_url=$(echo "$package_swift" | grep -A1 "name: \"grpcpp\"" | grep "url" | sed -E 's/.*url: "(.*)",.*/\1/')

# Check if the URL was extracted
if [[ -z $firebase_firestore_grpc_boringssl_url ]]; then
  echo "Failed to extract the BoringSSL-GRPC URL."
  exit 1
fi

if [[ -z $firebase_firestore_abseil_url ]]; then
  echo "Failed to extract the Firebase Firestore Abseil URL."
  exit 1
fi

if [[ -z $firebase_firestore_grpc_version_url ]]; then
  echo "Failed to extract the Firebase Firestore GPRC URL."
  exit 1
fi

if [[ -z $firebase_firestore_grpc_ccp_version_url ]]; then
  echo "Failed to extract the gRPC CPP version URL."
  exit 1
fi

# Check if the URL was extracted
if [[ -z $firebase_firestore_internal_url ]]; then
  echo "Failed to extract the URL for FirebaseFirestoreInternal."
  exit 1
fi

echo "firebase_firestore_abseil_url: $firebase_firestore_abseil_url"
echo "firebase_firestore_grpc_version_url: $firebase_firestore_grpc_version_url"
echo "firebase_firestore_grpc_boringssl_url: $firebase_firestore_grpc_boringssl_url"
echo "firebase_firestore_grpc_ccp_version_url: $firebase_firestore_grpc_ccp_version_url"
echo "firebase_firestore_internal_url: $firebase_firestore_internal_url"

# Output the variables in JSON format to a local temporary file. filename is passed as first argument.
cat <<EOF > $json_file_write_path
{
  "firebase_firestore_abseil_url": "$firebase_firestore_abseil_url",
  "firebase_firestore_grpc_version_url": "$firebase_firestore_grpc_version_url",
  "firebase_firestore_grpc_boringssl_url": "$firebase_firestore_grpc_boringssl_url",
  "firebase_firestore_grpc_ccp_version_url": "$firebase_firestore_grpc_ccp_version_url",
  "firebase_firestore_internal_url": "$firebase_firestore_internal_url"
}
EOF