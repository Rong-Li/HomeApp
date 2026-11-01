#!/bin/bash
set -euo pipefail

repo_root="$(rtk git rev-parse --show-toplevel)"
check_dir="$(rtk mktemp -d /tmp/homeapp-tab-loading.XXXXXX)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

rtk xcrun swiftc -parse-as-library -swift-version 5 \
    -module-cache-path "$check_dir/modules" \
    "$repo_root/HomeApp/Services/TabDataLoader.swift" \
    "$repo_root/Tests/TabLoading/TabLoadingChecks.swift" \
    -o "$check_dir/tab-loading-checks"
rtk "$check_dir/tab-loading-checks"
