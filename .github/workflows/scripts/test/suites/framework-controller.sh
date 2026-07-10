#!/bin/bash

suite_framework_controller() {
  echo "=== Suite: framework-controller.dart ==="
  local output
  local exit_code
  local github_env_file
  local start_ts
  local elapsed

  github_env_file=$(mktemp)

  test_start "early-exits for already complete release"
  start_ts=$(date +%s)
  set +e
  output=$(cd "$REPO_ROOT" && GITHUB_ENV="$github_env_file" dart "$SCRIPTS_DIR/framework-controller.dart" 2>&1)
  exit_code=$?
  set -e
  elapsed=$(( $(date +%s) - start_ts ))
  assert_exit_code 0 "$exit_code"
  assert_contains "$output" "already complete; skipping build"
  assert_contains "$(cat "$github_env_file")" "LATEST_FIREBASE_VERSION="
  assert_not_contains "$output" "New ZIP file created"

  test_start "early-exit completes quickly"
  if [ "$elapsed" -lt 900 ]; then
    assert_eq "fast" "fast" "completed in ${elapsed}s"
  else
    assert_eq "fast" "slow" "took ${elapsed}s; expected early exit under 900s"
  fi

  rm -f "$github_env_file"

  assert_suite_summary "framework-controller"
}
