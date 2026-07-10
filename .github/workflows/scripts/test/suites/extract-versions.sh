#!/bin/bash

suite_extract_versions() {
  echo "=== Suite: extract-versions.sh ==="
  local script="$SCRIPTS_DIR/extract-versions.sh"
  local workdir
  local output
  local exit_code
  local versions_file
  local github_env_file

  workdir=$(mktemp -d)
  versions_file="$workdir/versions.json"
  github_env_file="$workdir/github.env"

  pushd "$workdir" >/dev/null
  mkdir -p tmp

  test_start "writes valid version JSON"
  set +e
  output=$(GITHUB_ENV="$github_env_file" bash "$script" "$versions_file" 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 0 "$exit_code"
  assert_file_exists "$versions_file"
  latest_version=$(python3 - "$versions_file" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
required = [
  "firebase_firestore_version",
  "firebase_firestore_grpc_version",
  "firebase_firestore_leveldb_version",
  "firebase_firestore_nanopb_version",
  "firebase_firestore_abseil_version",
]
for key in required:
    assert data.get(key), f"missing {key}"
print(data["firebase_firestore_version"])
PY
)
  assert_contains "$output" "Latest Firebase Firestore version: $latest_version"

  test_start "writes LATEST_FIREBASE_VERSION to GITHUB_ENV"
  assert_file_exists "$github_env_file"
  assert_contains "$(cat "$github_env_file")" "LATEST_FIREBASE_VERSION=$latest_version"

  test_start "repo-add guard skips add when cocoapods repo exists (mocked)"
  mock_bin_init
  MOCK_REPO_HAS_COCOAPODS=1
  export MOCK_REPO_HAS_COCOAPODS
  set +e
  output=$(bash -c '
    if ! pod repo list 2>/dev/null | grep -qE "^cocoapods$"; then
      pod repo add cocoapods "https://github.com/CocoaPods/Specs.git"
    fi
    pod repo update cocoapods
  ' 2>&1)
  exit_code=$?
  repo_add_count=$(mock_repo_add_count)
  mock_bin_teardown
  set -e
  assert_exit_code 0 "$exit_code"
  assert_eq 0 "$repo_add_count" "repo add not called"
  assert_not_contains "$output" "destination path"

  popd >/dev/null
  rm -rf "$workdir"

  assert_suite_summary "extract-versions"
}
