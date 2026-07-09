#!/bin/bash

suite_write_firestore_privacy_manifest() {
  echo "=== Suite: write-firestore-privacy-manifest.sh ==="
  local script="$SCRIPTS_DIR/write-firestore-privacy-manifest.sh"
  local workdir
  local output
  local exit_code

  workdir=$(mktemp -d)
  pushd "$workdir" >/dev/null

  test_start "downloads valid plist for 12.16.0"
  set +e
  output=$(bash "$script" 12.16.0 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 0 "$exit_code"
  assert_file_exists "Resources/FirebaseFirestore.xcprivacy"
  assert_contains "$(head -3 Resources/FirebaseFirestore.xcprivacy)" "<?xml version=\"1.0\""
  assert_contains "$output" "valid plist/XML file"

  rm -rf Resources

  test_start "fails on HTTP error without saving junk plist"
  mock_bin_init
  MOCK_CURL_FORCE_FAIL=1
  export MOCK_CURL_FORCE_FAIL
  set +e
  output=$(bash "$script" 12.16.0 2>&1)
  exit_code=$?
  set -e
  mock_bin_teardown
  unset MOCK_CURL_FORCE_FAIL
  assert_exit_code 1 "$exit_code"
  if [ -f Resources/FirebaseFirestore.xcprivacy ]; then
    assert_not_contains "$(cat Resources/FirebaseFirestore.xcprivacy)" "<plist"
  else
    assert_eq "missing" "missing" "no junk file written"
  fi

  popd >/dev/null
  rm -rf "$workdir"

  assert_suite_summary "write-firestore-privacy-manifest"
}
