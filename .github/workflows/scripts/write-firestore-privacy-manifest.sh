#!/bin/bash
set -o pipefail

firebase_firestore_version=$1

# URL of the file to be downloaded
url="https://github.com/firebase/firebase-ios-sdk/raw/$firebase_firestore_version/Firestore/Swift/Source/Resources/PrivacyInfo.xcprivacy"

# Local directory and file path
local_dir="Resources"
local_file_path="$local_dir/FirebaseFirestore.xcprivacy"

# Create the local directory if it doesn't exist
mkdir -p "$local_dir"

# Download the file and fail on HTTP errors (e.g. 504 HTML responses).
if ! curl -sfL --retry 5 --retry-delay 10 --retry-all-errors "$url" -o "$local_file_path"; then
  echo "Failed to download the file from $url"
  exit 1
fi

echo "File downloaded successfully and written to $local_file_path"

# Check if the file is a plist/XML file
if grep -q "<?xml version=\"1.0\"" "$local_file_path" && grep -q "<plist" "$local_file_path"; then
  echo "FirebaseFirestore privacy manifest downloaded successfully and is a valid plist/XML file."
else
  echo "The downloaded file is not a valid plist/XML file."
  exit 1
fi
