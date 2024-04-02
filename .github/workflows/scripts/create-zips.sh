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

# Fetch the original ZIP file
curl -s "$raw_zip_url" -o "$temp_zip_path"

# Fetch the PrivacyInfo.xcprivacy file
curl -s "$privacy_manifest_url" -o "$temp_privacy_manifest_path"

# Check if the downloaded files exist
if [[ ! -f "$temp_zip_path" || ! -f "$temp_privacy_manifest_path" ]]; then
  echo "Failed to download necessary files."
  exit 1
fi

# Create a copy of the original ZIP file with a new name
cp "$temp_zip_path" "$path_to_new_zip"

# Add the PrivacyInfo.xcprivacy file to the new ZIP file
zip -j "$path_to_new_zip" "$temp_privacy_manifest_path"

# Clean up temporary files
rm "$temp_zip_path" "$temp_privacy_manifest_path"

echo "New ZIP file created at $path_to_new_zip"
