#!/bin/bash

start_local_http_server() {
  local serve_dir=$1
  local port
  port=$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)
  python3 -m http.server "$port" --directory "$serve_dir" >/dev/null 2>&1 &
  LOCAL_HTTP_SERVER_PID=$!
  LOCAL_HTTP_SERVER_PORT=$port
  sleep 1
}

stop_local_http_server() {
  if [ -n "${LOCAL_HTTP_SERVER_PID:-}" ]; then
    kill "$LOCAL_HTTP_SERVER_PID" >/dev/null 2>&1 || true
    wait "$LOCAL_HTTP_SERVER_PID" 2>/dev/null || true
  fi
}

suite_create_zips() {
  echo "=== Suite: create-zips.sh ==="
  local script="$SCRIPTS_DIR/create-zips.sh"
  local workdir
  local output
  local exit_code
  local privacy_url
  local zip_url
  local serve_dir

  workdir=$(mktemp -d)
  serve_dir="$workdir/serve"
  mkdir -p "$serve_dir" "$workdir/Archives" "$workdir/tmp"
  pushd "$workdir" >/dev/null

  echo "payload" >"$serve_dir/content.txt"
  (cd "$serve_dir" && zip -q tiny.zip content.txt)
  printf '%s\n' \
    '<?xml version="1.0" encoding="UTF-8"?>' \
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
    '<plist version="1.0"><dict/></plist>' \
    >"$serve_dir/PrivacyInfo.xcprivacy"

  start_local_http_server "$serve_dir"
  zip_url="http://127.0.0.1:${LOCAL_HTTP_SERVER_PORT}/tiny.zip"
  privacy_url="http://127.0.0.1:${LOCAL_HTTP_SERVER_PORT}/PrivacyInfo.xcprivacy"

  test_start "creates zip with privacy manifest from local HTTP server"
  set +e
  output=$(bash "$script" "$zip_url" "$privacy_url" "./Archives/test.zip" 2>&1)
  exit_code=$?
  set -e
  assert_exit_code 0 "$exit_code"
  assert_file_exists "Archives/test.zip"
  assert_contains "$output" "New ZIP file created"

  test_start "uses curl retry flags in script"
  assert_contains "$(cat "$script")" "--retry 5"
  assert_contains "$(cat "$script")" "--retry-all-errors"

  test_start "fails when download never succeeds"
  mock_bin_init
  MOCK_CURL_FORCE_FAIL=1
  export MOCK_CURL_FORCE_FAIL
  set +e
  output=$(bash "$script" "$zip_url" "$privacy_url" "./Archives/fail.zip" 2>&1)
  exit_code=$?
  set -e
  mock_bin_teardown
  unset MOCK_CURL_FORCE_FAIL
  assert_exit_code 1 "$exit_code"
  assert_contains "$output" "Failed to download"

  stop_local_http_server
  popd >/dev/null
  rm -rf "$workdir"

  assert_suite_summary "create-zips"
}
