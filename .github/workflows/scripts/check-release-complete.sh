#!/bin/bash
set -o pipefail

firebase_firestore_version=$1
firebase_firestore_grpc_version=$2
firebase_firestore_abseil_version=$3

if [ -z "$firebase_firestore_version" ]; then
  echo "Missing firebase_firestore_version argument."
  exit 2
fi

git fetch --tags --quiet 2>/dev/null || true

if ! git rev-parse "$firebase_firestore_version" >/dev/null 2>&1; then
  echo "Tag $firebase_firestore_version does not exist; release build required."
  exit 1
fi

if ! pod repo list 2>/dev/null | grep -qE '^cocoapods$'; then
  pod repo add cocoapods "https://github.com/CocoaPods/Specs.git"
fi
pod repo update cocoapods

pods_to_check=(
  "FirebaseFirestoreGRPCBoringSSLBinary:$firebase_firestore_grpc_version"
  "FirebaseFirestoreAbseilBinary:$firebase_firestore_abseil_version"
  "FirebaseFirestoreGRPCCoreBinary:$firebase_firestore_grpc_version"
  "FirebaseFirestoreGRPCCPPBinary:$firebase_firestore_grpc_version"
  "FirebaseFirestoreInternalBinary:$firebase_firestore_version"
  "FirebaseFirestoreBinary:$firebase_firestore_version"
)

for entry in "${pods_to_check[@]}"; do
  pod_name="${entry%%:*}"
  pod_version="${entry##*:}"
  if ! pod spec which "$pod_name" --version="$pod_version" >/dev/null 2>&1; then
    echo "$pod_name ($pod_version) not on CocoaPods trunk; release build required."
    exit 1
  fi
done

echo "Release $firebase_firestore_version is already complete (tag and all pods exist)."
exit 0
