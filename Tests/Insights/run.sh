#!/bin/bash
set -euo pipefail

repo_root="$(rtk git rev-parse --show-toplevel)"
check_dir="$(rtk mktemp -d /tmp/homeapp-insights-checks.XXXXXX)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

rtk xcrun swiftc -parse-as-library -swift-version 5 -default-isolation MainActor \
    -module-cache-path "$check_dir/modules" \
    "$repo_root"/HomeApp/Models/*.swift \
    "$repo_root/Tests/Insights/OfflineAPIService.swift" \
    "$repo_root/HomeApp/ViewModels/InsightsViewModel.swift" \
    "$repo_root/Tests/Insights/InsightsChecks.swift" \
    -o "$check_dir/insights-checks"
rtk "$check_dir/insights-checks"
