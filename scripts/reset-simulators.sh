#!/bin/bash

source "$(dirname "$0")/swift-version.sh"

while pgrep -q Simulator; do
    # Kill all the current simulator processes as they may be from a
    # different Xcode version
    pkill Simulator 2>/dev/null
    # CoreSimulatorService doesn't exit when sent SIGTERM
    pkill -9 Simulator 2>/dev/null
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
    xcrun simctl erase $udid &
done
wait

if [[ -a "${DEVELOPER_DIR}/Applications/Simulator.app" ]]; then
    open "${DEVELOPER_DIR}/Applications/Simulator.app"
fi

# Wait until the boot completes
echo "waiting for simulator to boot..."
while xcrun simctl list devices -j | jq -c -r '.devices | flatten | map(select(.availability == "(available)")) | map(select(.state == "Booted")) | length' | grep 0 >/dev/null; do
    sleep 1
done

# Sleep a bit before trying to open a URL because otherwise it somehow lengthens the boot time
sleep 30

# Wait until the simulator is fully booted by waiting for it to open a URL
until xcrun simctl openurl booted https://realm.io 2>/dev/null; do
    sleep 1
done

echo "simulator booted"
