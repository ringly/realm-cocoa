#!/bin/bash

source "$(dirname "$0")/swift-version.sh"

set -o pipefail
set -e

while pgrep -q Simulator; do
    # Kill all the current simulator processes as they may be from a
    # different Xcode version
    pkill Simulator 2>/dev/null || true
    # CoreSimulatorService doesn't exit when sent SIGTERM
    pkill -9 Simulator 2>/dev/null || true
done

# Install jq if needed
if ! which jq >/dev/null; then
    brew install jq
fi

# Shut down booted simulators
xcrun simctl list devices -j | jq -c -r '.devices | flatten | map(select(.availability == "(available)")) | map(select(.state == "Booted")) | map(.udid) | .[]' | while read udid; do
    echo "shutting down simulator with ID: $udid"
    xcrun simctl shutdown $udid
done

# Erase all available simulators
xcrun simctl list devices -j | jq -c -r '.devices | flatten | map(select(.availability == "(available)")) | map(.udid) | .[]' | while read udid; do
    echo "erasing simulator with ID: $udid"
    xcrun simctl erase $udid
done

if [[ -a "${DEVELOPER_DIR}/Applications/Simulator.app" ]]; then
    open "${DEVELOPER_DIR}/Applications/Simulator.app"
fi
