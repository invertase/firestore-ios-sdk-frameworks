#!/bin/bash
set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPTS_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
REPO_ROOT=$(cd "$SCRIPTS_DIR/../../.." && pwd)
export REPO_ROOT

# shellcheck source=lib/assert.sh
source "$SCRIPT_DIR/lib/assert.sh"
# shellcheck source=lib/mock-bin.sh
source "$SCRIPT_DIR/lib/mock-bin.sh"

TOTAL_PASSED=0
TOTAL_FAILED=0
SELECTED_SUITE=${1:-all}

run_suite() {
  local suite_file=$1
  local suite_name
  suite_name=$(basename "$suite_file" .sh)
  reset_assert_counters
  # shellcheck source=/dev/null
  source "$suite_file"
  case "$suite_name" in
    static) suite_static ;;
    check-release-complete) suite_check_release_complete ;;
    extract-versions) suite_extract_versions ;;
    write-firestore-privacy-manifest) suite_write_firestore_privacy_manifest ;;
    create-zips) suite_create_zips ;;
    release-lib) suite_release_lib ;;
    framework-controller) suite_framework_controller ;;
    *)
      echo "No runner registered for suite: $suite_name" >&2
      exit 2
      ;;
  esac
  TOTAL_PASSED=$((TOTAL_PASSED + TEST_ASSERT_PASSED))
  TOTAL_FAILED=$((TOTAL_FAILED + TEST_ASSERT_FAILED))
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [suite]

Suites:
  all                         Run every suite (default)
  static
  check-release-complete
  extract-versions
  write-firestore-privacy-manifest
  create-zips
  release-lib
  framework-controller

These tests are read-only with respect to GitHub and CocoaPods trunk.
They use temp directories and mocked git/pod/curl where mutation would occur.
EOF
}

case "$SELECTED_SUITE" in
  all)
    run_suite "$SCRIPT_DIR/suites/static.sh"
    run_suite "$SCRIPT_DIR/suites/check-release-complete.sh"
    run_suite "$SCRIPT_DIR/suites/extract-versions.sh"
    run_suite "$SCRIPT_DIR/suites/write-firestore-privacy-manifest.sh"
    run_suite "$SCRIPT_DIR/suites/create-zips.sh"
    run_suite "$SCRIPT_DIR/suites/release-lib.sh"
    run_suite "$SCRIPT_DIR/suites/framework-controller.sh"
    ;;
  static|check-release-complete|extract-versions|write-firestore-privacy-manifest|create-zips|release-lib|framework-controller)
    run_suite "$SCRIPT_DIR/suites/$SELECTED_SUITE.sh"
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown suite: $SELECTED_SUITE" >&2
    usage
    exit 2
    ;;
esac

echo ""
echo "========================================"
echo "Total: $TOTAL_PASSED passed, $TOTAL_FAILED failed"
echo "========================================"

if [ "$TOTAL_FAILED" -gt 0 ]; then
  exit 1
fi
