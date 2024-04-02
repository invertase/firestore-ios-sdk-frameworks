#!/bin/bash
set -o pipefail
firebase_firestore_version=$1
firebase_firestore_abseil_version=$2
firebase_firestore_grpc_version=$3
firebase_firestore_leveldb_version=$4
firebase_firestore_nanopb_version_min=$5
firebase_firestore_nanopb_version_max=$6
firebase_firestore_grpc_version_url=$7
firebase_firestore_abseil_url=$8
firebase_firestore_internal_url=$9
firebase_firestore_grpc_boringssl_url=${10}
firebase_firestore_grpc_ccp_version_url=${11}

# UPDATE THE VARIABLES IN EACH PODSPEC FILE
# for file in *.podspec; do
#   sed -i '' "s|firebase_firestore_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_version='$firebase_firestore_version'|" "$file"
#   sed -i '' "s|firebase_firestore_abseil_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_abseil_version='$firebase_firestore_abseil_version'|" "$file"
#   sed -i '' "s|firebase_firestore_grpc_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_version='$firebase_firestore_grpc_version'|" "$file"
#   sed -i '' "s|firebase_firestore_leveldb_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_leveldb_version='$firebase_firestore_leveldb_version'|" "$file"
#   sed -i '' "s|firebase_firestore_nanopb_version_min[[:space:]]*=[[:space:]]*.*|firebase_firestore_nanopb_version_min='$firebase_firestore_nanopb_version_min'|" "$file"
#   sed -i '' "s|firebase_firestore_nanopb_version_max[[:space:]]*=[[:space:]]*.*|firebase_firestore_nanopb_version_max='$firebase_firestore_nanopb_version_max'|" "$file"
#   sed -i '' "s|firebase_firestore_abseil_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_abseil_url='$firebase_firestore_abseil_url'|" "$file"
#   sed -i '' "s|firebase_firestore_grpc_ccp_version_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_ccp_version_url='$firebase_firestore_grpc_ccp_version_url'|" "$file"
#   sed -i '' "s|firebase_firestore_grpc_version_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_version_url='$firebase_firestore_grpc_version_url'|" "$file"
#   sed -i '' "s|firebase_firestore_grpc_boringssl_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_boringssl_url='$firebase_firestore_grpc_boringssl_url'|" "$file"
#   sed -i '' "s|firebase_firestore_internal_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_internal_url='$firebase_firestore_internal_url'|" "$file"
# done

# Uncomment if you wish to run script locally from scripts directory
for file in *.podspec ../../../*.podspec; do
  if [[ -f "$file" ]]; then
    sed -i '' "s|firebase_firestore_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_version='$firebase_firestore_version'|" "$file"
    sed -i '' "s|firebase_firestore_abseil_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_abseil_version='$firebase_firestore_abseil_version'|" "$file"
    sed -i '' "s|firebase_firestore_grpc_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_version='$firebase_firestore_grpc_version'|" "$file"
    sed -i '' "s|firebase_firestore_leveldb_version[[:space:]]*=[[:space:]]*.*|firebase_firestore_leveldb_version='$firebase_firestore_leveldb_version'|" "$file"
    sed -i '' "s|firebase_firestore_nanopb_version_min[[:space:]]*=[[:space:]]*.*|firebase_firestore_nanopb_version_min='$firebase_firestore_nanopb_version_min'|" "$file"
    sed -i '' "s|firebase_firestore_nanopb_version_max[[:space:]]*=[[:space:]]*.*|firebase_firestore_nanopb_version_max='$firebase_firestore_nanopb_version_max'|" "$file"
    sed -i '' "s|firebase_firestore_abseil_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_abseil_url='$firebase_firestore_abseil_url'|" "$file"
    sed -i '' "s|firebase_firestore_grpc_ccp_version_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_ccp_version_url='$firebase_firestore_grpc_ccp_version_url'|" "$file"
    sed -i '' "s|firebase_firestore_grpc_version_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_version_url='$firebase_firestore_grpc_version_url'|" "$file"
    sed -i '' "s|firebase_firestore_grpc_boringssl_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_grpc_boringssl_url='$firebase_firestore_grpc_boringssl_url'|" "$file"
    sed -i '' "s|firebase_firestore_internal_url[[:space:]]*=[[:space:]]*.*|firebase_firestore_internal_url='$firebase_firestore_internal_url'|" "$file"
  fi
done