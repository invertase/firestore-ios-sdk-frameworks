#!/bin/bash
set -o pipefail

# THE JSON path for outputs
json_file_write_path=$1

firebase_firestore_abseil_version=$2
firebase_firestore_grpc_version=$3

# abseil URL extraction
abseil_cpp_binary_url="https://raw.githubusercontent.com/google/abseil-cpp-binary/$firebase_firestore_abseil_version/Package.swift"

# Fetch the Package.swift file
echo "Fetching Package.swift file from $abseil_cpp_binary_url"
abseil_cpp_binary_package_swift=$(curl -s $abseil_cpp_binary_url)

# Check if the fetch was successful
if [[ -z $abseil_cpp_binary_package_swift ]]; then
  echo "Failed to fetch the Package.swift abseil cpp binary file."
  exit 1
fi

# Extract the path ("absl-Wrapper")
abseil_path=$(echo "$abseil_cpp_binary_package_swift" | grep -o 'path: "[^"]*"' | sed -E 's/path: "([^"]*)"/\1/' | head -1)

# Extract the resource process path ("Resources/PrivacyInfo.xcprivacy")
abseil_resource_process_path=$(echo "$abseil_cpp_binary_package_swift" | grep -o 'process("[^"]*")' | sed -E 's/process\("([^"]*)"\)/\1/' | head -1)

abseil_privacy_resource_url="https://raw.githubusercontent.com/google/abseil-cpp-binary/$firebase_firestore_abseil_version/$abseil_path/$abseil_resource_process_path"

# GRPC URL extraction

# URL of the grpc binary Package.swift file
grpc_binary_swift_url="https://raw.githubusercontent.com/google/grpc-binary/$firebase_firestore_grpc_version/Package.swift"


# Fetch the Package.swift file
echo "Fetching Package.swift file from $grpc_binary_swift_url"
package_swift=$(curl -s $grpc_binary_swift_url)

# Extract the section for the grpcWrapper target
grpc_wrapper_section=$(echo "$package_swift" | awk '/grpcWrapper/,/}/' | grep -v 'opensslWrapper\|grpcppWrapper')

# Extract the path value for grpcWrapper
grpc_wrapper_path=$(echo "$grpc_wrapper_section" | grep -m1 'path: ' | sed -E 's/.*path: "([^"]*)".*/\1/')

# Extract the resource process path for grpcWrapper
grpc_wrapper_resource_process_path=$(echo "$grpc_wrapper_section" | grep -m1 'process(' | sed -E 's/.*process\("([^"]*)"\).*/\1/')

grpc_privacy_resource_url="https://raw.githubusercontent.com/google/grpc-binary/$firebase_firestore_grpc_version/$grpc_wrapper_path/$grpc_wrapper_resource_process_path"


# GRPC Open SSL URL extraction

# Use URL of the gRPC binary Package.swift file to get the privacy resource for open_ssl
# Extract the section for the opensslWrapper target
openssl_wrapper_section=$(echo "$package_swift" | awk '/opensslWrapper/,/}/' | grep -v 'grpcWrapper\|grpcppWrapper')

# Extract the path value for opensslWrapper
openssl_wrapper_path=$(echo "$openssl_wrapper_section" | grep -m1 'path: ' | sed -E 's/.*path: "([^"]*)".*/\1/')

# Extract the resource process path for opensslWrapper
openssl_wrapper_resource_process_path=$(echo "$openssl_wrapper_section" | grep -m1 'process(' | sed -E 's/.*process\("([^"]*)"\).*/\1/')

open_ssl_privacy_resource_url="https://raw.githubusercontent.com/google/grpc-binary/$firebase_firestore_grpc_version/$openssl_wrapper_path/$openssl_wrapper_resource_process_path"


# GRPCPP URL extraction

# Extract the URL of the grpcpp zip for the podspec
firebase_firestore_grpc_ccp_version_url=$(echo "$package_swift" | grep -A1 "name: \"grpcpp\"" | grep "url" | sed -E 's/.*url: "(.*)",.*/\1/')

# Extract the section for the grpcppWrapper target
grpcpp_wrapper_section=$(echo "$package_swift" | sed -n '/name: "grpcppWrapper"/,/^ *},/p' | grep -v 'name: "grpcWrapper"\|name: "opensslWrapper"')

# Extract the path value for grpcppWrapper
grpcpp_wrapper_path=$(echo "$grpcpp_wrapper_section" | grep -m1 'path: ' | sed -E 's/.*path: "([^"]*)".*/\1/')

# Extract the resource process path for grpcppWrapper
grpcpp_wrapper_resource_process_path=$(echo "$grpcpp_wrapper_section" | grep -m1 'process(' | sed -E 's/.*process\("([^"]*)"\).*/\1/')


grpcpp_privacy_resource_url="https://raw.githubusercontent.com/google/grpc-binary/$firebase_firestore_grpc_version/$grpcpp_wrapper_path/$grpcpp_wrapper_resource_process_path"

# Check the URLS were extracted
if [[ -z $grpcpp_privacy_resource_url ]]; then
  echo "Failed to extract the GRPCPP privacy manifest URL."
  exit 1
fi

if [[ -z $open_ssl_privacy_resource_url ]]; then
  echo "Failed to extract the GRPCPP privacy manifest URL."
  exit 1
fi

if [[ -z $grpc_privacy_resource_url ]]; then
  echo "Failed to extract the GRPC privacy manifest URL."
  exit 1
fi

if [[ -z $abseil_privacy_resource_url ]]; then
  echo "Failed to extract the abseil privacy manifest URL."
  exit 1
fi

mkdir -p ./tmp

echo "Writing the privacy manifest URLs to $json_file_write_path"
# Output the variables in JSON format to a local temporary file. filename is passed as first argument.
cat <<EOF > $json_file_write_path
{
  "grpcpp_privacy_resource_url": "$grpcpp_privacy_resource_url",
  "open_ssl_privacy_resource_url": "$open_ssl_privacy_resource_url",
  "grpc_privacy_resource_url": "$grpc_privacy_resource_url",
  "abseil_privacy_resource_url": "$abseil_privacy_resource_url"
}
EOF