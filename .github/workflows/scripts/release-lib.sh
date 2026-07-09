#!/bin/bash

POD_TRUNK_MAX_ATTEMPTS=${POD_TRUNK_MAX_ATTEMPTS:-3}
POD_TRUNK_RETRY_DELAY_SECONDS=${POD_TRUNK_RETRY_DELAY_SECONDS:-60}
POD_TRUNK_POST_PUBLISH_SLEEP_SECONDS=${POD_TRUNK_POST_PUBLISH_SLEEP_SECONDS:-300}

ensure_cocoapods_repo() {
  if ! pod repo list 2>/dev/null | grep -qE '^cocoapods$'; then
    pod repo add cocoapods "https://github.com/CocoaPods/Specs.git"
  fi
  pod repo update cocoapods
}

pod_exists_on_trunk() {
  local pod_name=$1
  local pod_version=$2
  pod spec which "$pod_name" --version="$pod_version" >/dev/null 2>&1
}

# Pushes a podspec when missing. Verifies trunk state after each attempt so a
# successful publish is not reported as failure when the GitHub commit API times out.
push_pod_if_missing() {
  local pod_name=$1
  local pod_version=$2
  local podspec_file=$3
  local attempt=1

  ensure_cocoapods_repo
  echo "Running 'pod spec which $pod_name --version=$pod_version'"
  if pod_exists_on_trunk "$pod_name" "$pod_version"; then
    echo "$pod_name already exists"
    return 0
  fi

  while [ $attempt -le $POD_TRUNK_MAX_ATTEMPTS ]; do
    echo "Pushing $pod_name ($pod_version), attempt $attempt/$POD_TRUNK_MAX_ATTEMPTS"
    pod trunk push "$podspec_file" --allow-warnings --skip-tests --skip-import-validation --synchronous || true

    ensure_cocoapods_repo
    if pod_exists_on_trunk "$pod_name" "$pod_version"; then
      echo "$pod_name ($pod_version) confirmed on CocoaPods trunk"
      if [ "$POD_TRUNK_POST_PUBLISH_SLEEP_SECONDS" -gt 0 ]; then
        sleep "$POD_TRUNK_POST_PUBLISH_SLEEP_SECONDS"
      fi
      return 0
    fi

    echo "$pod_name ($pod_version) not yet visible on trunk after attempt $attempt"
    attempt=$((attempt + 1))
    if [ $attempt -le $POD_TRUNK_MAX_ATTEMPTS ]; then
      sleep "$POD_TRUNK_RETRY_DELAY_SECONDS"
    fi
  done

  echo "Failed to push $pod_name after $POD_TRUNK_MAX_ATTEMPTS attempts"
  return 1
}
