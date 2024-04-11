#!/bin/bash
set -o pipefail

# Assigning passed arguments to variables
raw_zip_url=$1
privacy_manifest_url=$2
path_to_new_zip=$3

# Temporary paths
temp_zip_path="./tmp/temp.zip"
temp_privacy_manifest_path="./tmp/PrivacyInfo.xcprivacy"

# Create the directory for the new ZIP file if it doesn't exist
new_zip_dir=$(dirname "$path_to_new_zip")
mkdir -p "$new_zip_dir"

# Fetch the original ZIP file, fail if HTTP request fails (e.g., with a 404)
if ! curl -sf "$raw_zip_url" -o "$temp_zip_path"; then
  echo "Failed to download ZIP file (URL might be invalid or file not found)."
  exit 1
fi

# Fetch the PrivacyInfo.xcprivacy file, fail if HTTP request fails
if ! curl -sf "$privacy_manifest_url" -o "$temp_privacy_manifest_path"; then
  echo "Failed to download PrivacyInfo.xcprivacy file (URL might be invalid or file not found)."
  exit 1
fi

# Check if the downloaded files exist
if [[ ! -f "$temp_zip_path" || ! -f "$temp_privacy_manifest_path" ]]; then
  echo "Failed to download necessary files."
  exit 1
fi

# Create a copy of the original ZIP file with a new name
cp "$temp_zip_path" "$path_to_new_zip"

# Add the PrivacyInfo.xcprivacy file to the new ZIP file
zip -j "$path_to_new_zip" "$temp_privacy_manifest_path"
zip_exit_status=$?

# Check if zip operation was successful
if [[ $zip_exit_status -ne 0 ]]; then
    echo "Failed to create the ZIP file."
    rm -f "$path_to_new_zip"
    rm -f "$temp_zip_path" "$temp_privacy_manifest_path"
    exit $zip_exit_status
fi

# Clean up temporary files
rm -f "$temp_zip_path" "$temp_privacy_manifest_path"

echo "New ZIP file created at $path_to_new_zip"
