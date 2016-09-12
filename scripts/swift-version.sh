#!/usr/bin/env bash

: ${REALM_SWIFT_VERSION:=3.0}

if ! [ -z "${TOOLCHAINS}" ]; then
  # exiting early since TOOLCHAINS has already been set
  return
fi

clean_swift_version() {
  version="$1"

  # echo "getting clean version for $version"
  if [ "$version" == "XcodeDefault" ]; then
    version_line="$(env DEVELOPER_DIR="$xcode" xcrun swift --version | head -n1)"
    version="swift-$(echo "$version_line" | cut -d " " -f 4)"
  fi

  # Swift toolchains start with `swift-`.
  # For example: swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a
  version="${version##swift-}"

  # Xcode swift toolchains start with `Swift_`.
  # For example: Swift_2.3
  version="${version##Swift_}"
  echo "$version"
}

find_xcode_for_swift() {
  requested_swift_version="$1"
  XCODES="$(mdfind "kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'" 2>/dev/null)"
  for xcode in $XCODES; do
    dev_dir="$xcode/Contents/Developer"

    for toolchain_path in "$dev_dir/Toolchains"/*; do
      if [[ "$toolchain_path" == *".xctoolchain" ]] && [ -d "$toolchain_path" ]; then
        version=$(clean_swift_version "$(basename ${toolchain_path##*/} .xctoolchain)")

        if [ "$version" == "$requested_swift_version" ]; then
          export DEVELOPER_DIR="$dev_dir"
          export TOOLCHAINS="$toolchain_path"
          return
        fi
      fi
    done
  done
  echo "could not find Swift version $requested_swift_version"
  exit 1
}

find_xcode_for_swift $REALM_SWIFT_VERSION
