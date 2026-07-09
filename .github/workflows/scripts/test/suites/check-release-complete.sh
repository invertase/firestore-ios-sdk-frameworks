#!/bin/bash

suite_check_release_complete() {
  echo "=== Suite: check-release-complete.sh ==="
  local script="$SCRIPTS_DIR/check-release-complete.sh"
  local output
  local exit_code

  test_start "complete release exits 0"
  set +e
  output=$(bash "$script" 12.16.0 1.69.0 1.2024072200.0 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "already complete"

  test_start "missing tag exits 1"
  set +e
  output=$(bash "$script" 99.99.99 1.69.0 1.2024072200.0 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "does not exist"

  test_start "missing pod exits 1"
  set +e
  output=$(bash "$script" 12.16.0 9.99.9 1.2024072200.0 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "not on CocoaPods trunk"

  test_start "missing args exits 2"
  set +e
  output=$(bash "$script" 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 2 "$exit_code"
  assert_contains "$output" "Missing firebase_firestore_version"

  assert_suite_summary "check-release-complete"
}
