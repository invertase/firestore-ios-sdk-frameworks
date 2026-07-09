#!/bin/bash

suite_release_lib() {
  echo "=== Suite: release-lib.sh / push_pod_if_missing ==="
  local output
  local exit_code

  POD_TRUNK_MAX_ATTEMPTS=3
  POD_TRUNK_RETRY_DELAY_SECONDS=0
  POD_TRUNK_POST_PUBLISH_SLEEP_SECONDS=0
  export POD_TRUNK_MAX_ATTEMPTS POD_TRUNK_RETRY_DELAY_SECONDS POD_TRUNK_POST_PUBLISH_SLEEP_SECONDS

  test_start "already published pod skips trunk push"
  mock_bin_init
  mock_add_spec "FirebaseFirestoreBinary" "12.16.0"
  # shellcheck source=../../release-lib.sh
  source "$SCRIPTS_DIR/release-lib.sh"
  set +e
  output=$(push_pod_if_missing FirebaseFirestoreBinary 12.16.0 FirebaseFirestoreBinary.podspec 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "already exists"
  assert_eq 0 "$(mock_trunk_push_count)"
  mock_bin_teardown

  test_start "false-negative trunk push still succeeds when spec appears"
  mock_bin_init
  MOCK_TRUNK_PUSH_FAILS=1
  MOCK_TRUNK_PUSH_EXIT=1
  MOCK_VISIBLE_AFTER_PUSH=1
  echo 1 >"$MOCK_STATE_DIR/trunk_push_failures_remaining"
  export MOCK_TRUNK_PUSH_FAILS MOCK_TRUNK_PUSH_EXIT MOCK_VISIBLE_AFTER_PUSH
  # shellcheck source=../../release-lib.sh
  source "$SCRIPTS_DIR/release-lib.sh"
  set +e
  output=$(push_pod_if_missing FirebaseFirestoreBinary 1.0.0-test FirebaseFirestoreBinary.podspec 2>&1)
  exit_code=$?
  trunk_push_count=$(mock_trunk_push_count)
  mock_bin_teardown
  set -e
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "confirmed on CocoaPods trunk"
  assert_eq 2 "$trunk_push_count" "push attempted twice before spec visible"

  test_start "true failure exits non-zero after max attempts"
  mock_bin_init
  MOCK_TRUNK_PUSH_FAILS=99
  MOCK_VISIBLE_AFTER_PUSH=0
  echo 99 >"$MOCK_STATE_DIR/trunk_push_failures_remaining"
  export MOCK_TRUNK_PUSH_FAILS MOCK_VISIBLE_AFTER_PUSH
  # shellcheck source=../../release-lib.sh
  source "$SCRIPTS_DIR/release-lib.sh"
  set +e
  output=$(push_pod_if_missing FirebaseFirestoreBinary 9.9.9 FirebaseFirestoreBinary.podspec 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "Failed to push FirebaseFirestoreBinary"
  assert_eq 3 "$(mock_trunk_push_count)"
  mock_bin_teardown

  test_start "ensure_cocoapods_repo skips add when repo exists"
  mock_bin_init
  MOCK_REPO_HAS_COCOAPODS=1
  export MOCK_REPO_HAS_COCOAPODS
  # shellcheck source=../../release-lib.sh
  source "$SCRIPTS_DIR/release-lib.sh"
  ensure_cocoapods_repo
  assert_eq 0 "$(mock_repo_add_count)"
  mock_bin_teardown

  test_start "ensure_cocoapods_repo adds repo when missing"
  mock_bin_init
  MOCK_REPO_HAS_COCOAPODS=0
  export MOCK_REPO_HAS_COCOAPODS
  # shellcheck source=../../release-lib.sh
  source "$SCRIPTS_DIR/release-lib.sh"
  ensure_cocoapods_repo
  assert_eq 1 "$(mock_repo_add_count)"
  mock_bin_teardown

  assert_suite_summary "release-lib"
}
