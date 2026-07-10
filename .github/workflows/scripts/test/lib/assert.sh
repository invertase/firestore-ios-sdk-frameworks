#!/bin/bash

TEST_ASSERT_PASSED=0
TEST_ASSERT_FAILED=0
TEST_ASSERT_CURRENT=""

test_start() {
  TEST_ASSERT_CURRENT=$1
}

assert_eq() {
  local expected=$1
  local actual=$2
  local message=${3:-}

  if [ "$expected" = "$actual" ]; then
    TEST_ASSERT_PASSED=$((TEST_ASSERT_PASSED + 1))
    echo "  ok: $TEST_ASSERT_CURRENT${message:+ ($message)}"
    return 0
  fi

  TEST_ASSERT_FAILED=$((TEST_ASSERT_FAILED + 1))
  echo "  FAIL: $TEST_ASSERT_CURRENT"
  echo "        expected: $expected"
  echo "        actual:   $actual"
  if [ -n "$message" ]; then
    echo "        note:     $message"
  fi
  return 1
}

assert_contains() {
  local haystack=$1
  local needle=$2
  local message=${3:-}

  if [[ "$haystack" == *"$needle"* ]]; then
    TEST_ASSERT_PASSED=$((TEST_ASSERT_PASSED + 1))
    echo "  ok: $TEST_ASSERT_CURRENT${message:+ ($message)}"
    return 0
  fi

  TEST_ASSERT_FAILED=$((TEST_ASSERT_FAILED + 1))
  echo "  FAIL: $TEST_ASSERT_CURRENT"
  echo "        expected output to contain: $needle"
  if [ -n "$message" ]; then
    echo "        note: $message"
  fi
  return 1
}

assert_not_contains() {
  local haystack=$1
  local needle=$2
  local message=${3:-}

  if [[ "$haystack" != *"$needle"* ]]; then
    TEST_ASSERT_PASSED=$((TEST_ASSERT_PASSED + 1))
    echo "  ok: $TEST_ASSERT_CURRENT${message:+ ($message)}"
    return 0
  fi

  TEST_ASSERT_FAILED=$((TEST_ASSERT_FAILED + 1))
  echo "  FAIL: $TEST_ASSERT_CURRENT"
  echo "        expected output NOT to contain: $needle"
  if [ -n "$message" ]; then
    echo "        note: $message"
  fi
  return 1
}

assert_file_exists() {
  local file_path=$1
  local message=${2:-}

  if [ -f "$file_path" ]; then
    TEST_ASSERT_PASSED=$((TEST_ASSERT_PASSED + 1))
    echo "  ok: $TEST_ASSERT_CURRENT${message:+ ($message)}"
    return 0
  fi

  TEST_ASSERT_FAILED=$((TEST_ASSERT_FAILED + 1))
  echo "  FAIL: $TEST_ASSERT_CURRENT"
  echo "        missing file: $file_path"
  return 1
}

assert_exit_code() {
  local expected=$1
  local actual=$2
  assert_eq "$expected" "$actual" "exit code"
}

assert_suite_summary() {
  local suite_name=$1
  echo ""
  echo "Suite $suite_name: $TEST_ASSERT_PASSED passed, $TEST_ASSERT_FAILED failed"
}

reset_assert_counters() {
  TEST_ASSERT_PASSED=0
  TEST_ASSERT_FAILED=0
  TEST_ASSERT_CURRENT=""
}
