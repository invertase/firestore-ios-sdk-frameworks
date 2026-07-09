#!/bin/bash

suite_static() {
  echo "=== Suite: static checks ==="

  test_start "dart analyze passes"
  if (cd "$SCRIPTS_DIR" && dart pub get >/dev/null 2>&1 && dart analyze >/dev/null 2>&1); then
    assert_eq 0 0 "dart analyze"
  else
    assert_eq 0 1 "dart analyze"
  fi

  if command -v shellcheck >/dev/null 2>&1; then
    test_start "shellcheck passes for modified release scripts"
    if shellcheck -x -e SC1091,SC2086,SC2034,SC2155 \
      "$SCRIPTS_DIR/release-lib.sh" \
      "$SCRIPTS_DIR/check-release-complete.sh" \
      "$SCRIPTS_DIR/write-firestore-privacy-manifest.sh" \
      "$SCRIPTS_DIR/create-zips.sh" \
      "$SCRIPTS_DIR/commit-and-publish.sh" \
      "$SCRIPTS_DIR/extract-versions.sh" \
      "$SCRIPT_DIR/lib/assert.sh" \
      "$SCRIPT_DIR/lib/mock-bin.sh" \
      "$SCRIPT_DIR/run-tests.sh" \
      >/dev/null 2>&1; then
      assert_eq 0 0 "shellcheck"
    else
      shellcheck -x -e SC1091,SC2086,SC2034,SC2155 \
        "$SCRIPTS_DIR/release-lib.sh" \
        "$SCRIPTS_DIR/check-release-complete.sh" \
        "$SCRIPTS_DIR/write-firestore-privacy-manifest.sh" \
        "$SCRIPTS_DIR/create-zips.sh" \
        "$SCRIPTS_DIR/commit-and-publish.sh" \
        "$SCRIPTS_DIR/extract-versions.sh" \
        "$SCRIPT_DIR/lib/assert.sh" \
        "$SCRIPT_DIR/lib/mock-bin.sh" \
        "$SCRIPT_DIR/run-tests.sh"
      assert_eq 0 1 "shellcheck"
    fi
  else
    test_start "shellcheck available"
    echo "  skip: shellcheck not installed"
  fi

  assert_suite_summary "static"
}
