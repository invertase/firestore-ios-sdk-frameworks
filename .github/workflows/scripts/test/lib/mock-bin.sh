#!/bin/bash

mock_bin_init() {
  MOCK_BIN_DIR=$(mktemp -d)
  export MOCK_BIN_DIR
  MOCK_STATE_DIR=$(mktemp -d)
  export MOCK_STATE_DIR
  export PATH="$MOCK_BIN_DIR:$PATH"

  : >"$MOCK_STATE_DIR/trunk_push.log"
  : >"$MOCK_STATE_DIR/repo_add.log"
  : >"$MOCK_STATE_DIR/repo_update.log"
  : >"$MOCK_STATE_DIR/spec_queries.log"
  : >"$MOCK_STATE_DIR/curl_urls.log"
  : >"$MOCK_STATE_DIR/specs.txt"
  echo 0 >"$MOCK_STATE_DIR/trunk_push_failures_remaining"

  MOCK_TRUNK_PUSH_FAILS=${MOCK_TRUNK_PUSH_FAILS:-0}
  MOCK_TRUNK_PUSH_EXIT=${MOCK_TRUNK_PUSH_EXIT:-1}
  MOCK_REPO_HAS_COCOAPODS=${MOCK_REPO_HAS_COCOAPODS:-1}
  MOCK_VISIBLE_AFTER_PUSH=${MOCK_VISIBLE_AFTER_PUSH:-0}
  echo "$MOCK_TRUNK_PUSH_FAILS" >"$MOCK_STATE_DIR/trunk_push_failures_remaining"
  export MOCK_TRUNK_PUSH_EXIT MOCK_REPO_HAS_COCOAPODS MOCK_VISIBLE_AFTER_PUSH MOCK_STATE_DIR

  mock_install_all
}

mock_bin_teardown() {
  if [ -n "${MOCK_BIN_DIR:-}" ] && [ -d "$MOCK_BIN_DIR" ]; then
    rm -rf "$MOCK_BIN_DIR"
  fi
  if [ -n "${MOCK_STATE_DIR:-}" ] && [ -d "$MOCK_STATE_DIR" ]; then
    rm -rf "$MOCK_STATE_DIR"
  fi
}

mock_add_spec() {
  local pod_name=$1
  local pod_version=$2
  echo "$pod_name $pod_version" >>"$MOCK_STATE_DIR/specs.txt"
}

mock_install_pod() {
  cat >"$MOCK_BIN_DIR/pod" <<'EOF'
#!/bin/bash
set -o pipefail

case "$1" in
  repo)
    case "$2" in
      list)
        if [ "$MOCK_REPO_HAS_COCOAPODS" = "1" ]; then
          echo "cocoapods"
          echo "- Type: git (master)"
        fi
        exit 0
        ;;
      add)
        echo "mock pod repo add $3" >>"$MOCK_STATE_DIR/repo_add.log"
        exit 0
        ;;
      update)
        echo "mock pod repo update ${3:-}" >>"$MOCK_STATE_DIR/repo_update.log"
        exit 0
        ;;
    esac
    ;;
  spec)
    if [ "$2" = "which" ]; then
      pod_name=$3
      shift 3
      pod_version=""
      while [ $# -gt 0 ]; do
        case "$1" in
          --version=*)
            pod_version=${1#--version=}
            ;;
          --version)
            shift
            pod_version=$1
            ;;
        esac
        shift
      done
      echo "query $pod_name $pod_version" >>"$MOCK_STATE_DIR/spec_queries.log"
      if grep -qx "$pod_name $pod_version" "$MOCK_STATE_DIR/specs.txt"; then
        echo "/mock/specs/$pod_name/$pod_version.podspec.json"
        exit 0
      fi
      echo "[!] Can't find spec for $pod_name." >&2
      exit 1
    fi
    ;;
  trunk)
    if [ "$2" = "push" ]; then
      podspec_file=$3
      echo "trunk push $podspec_file" >>"$MOCK_STATE_DIR/trunk_push.log"
      remaining=$(cat "$MOCK_STATE_DIR/trunk_push_failures_remaining")
      if [ "$remaining" -gt 0 ]; then
        echo $((remaining - 1)) >"$MOCK_STATE_DIR/trunk_push_failures_remaining"
        exit "$MOCK_TRUNK_PUSH_EXIT"
      fi
      if [ "$MOCK_VISIBLE_AFTER_PUSH" = "1" ]; then
        base_name=$(basename "$podspec_file" .podspec)
        echo "$base_name 1.0.0-test" >>"$MOCK_STATE_DIR/specs.txt"
      fi
      exit 0
    fi
    ;;
esac

echo "mock pod: unsupported command: $*" >&2
exit 127
EOF
  chmod +x "$MOCK_BIN_DIR/pod"
}

mock_install_curl() {
  local real_curl
  real_curl=$(command -v curl)

  cat >"$MOCK_BIN_DIR/curl" <<EOF
#!/bin/bash
set -o pipefail

if [ "\${MOCK_CURL_FORCE_FAIL:-0}" = "1" ]; then
  exit 22
fi

for arg in "\$@"; do
  case "\$arg" in
    http://*|https://*)
      echo "\$arg" >>"$MOCK_STATE_DIR/curl_urls.log"
      ;;
  esac
done

if [ -n "\${MOCK_CURL_FAIL_PATTERN:-}" ]; then
  for arg in "\$@"; do
    if [[ "\$arg" == *"\$MOCK_CURL_FAIL_PATTERN"* ]]; then
      current=\$(cat "$MOCK_STATE_DIR/curl_fail_count" 2>/dev/null || echo 0)
      if [ "\$current" -lt "\${MOCK_CURL_FAIL_UNTIL:-0}" ]; then
        echo \$((current + 1)) >"$MOCK_STATE_DIR/curl_fail_count"
        exit 22
      fi
    fi
  done
fi

exec "$real_curl" "\$@"
EOF
  chmod +x "$MOCK_BIN_DIR/curl"
}

mock_install_git() {
  local real_git
  real_git=$(command -v git)

  cat >"$MOCK_BIN_DIR/git" <<EOF
#!/bin/bash
set -o pipefail

if [[ "\$*" == *"push"* ]] || [[ "\$*" == *"commit"* ]] || [[ "\$*" == *" tag"* ]] || [[ "\$1" == "tag" ]]; then
  echo "mock git blocked mutating command: git \$*" >&2
  exit 1
fi

exec "$real_git" "\$@"
EOF
  chmod +x "$MOCK_BIN_DIR/git"
}

mock_install_sleep() {
  cat >"$MOCK_BIN_DIR/sleep" <<'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "$MOCK_BIN_DIR/sleep"
}

mock_install_all() {
  mock_install_pod
  mock_install_curl
  mock_install_git
  mock_install_sleep
}

mock_trunk_push_count() {
  wc -l <"$MOCK_STATE_DIR/trunk_push.log" | tr -d ' '
}

mock_repo_add_count() {
  wc -l <"$MOCK_STATE_DIR/repo_add.log" | tr -d ' '
}
