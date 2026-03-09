#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: xforge-android-linker.sh <rust-target-triple> [clang args...]" >&2
  exit 2
fi

target="$1"
shift
api="${XFORGE_ANDROID_API:-23}"

pick_latest_ndk() {
  local base="$1"
  if [[ ! -d "$base" ]]; then
    return 1
  fi
  ls -1 "$base" 2>/dev/null | sort -V | tail -n 1
}

resolve_ndk_root() {
  local ndk_home="${XFORGE_ANDROID_NDK:-${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}}"
  if [[ -n "$ndk_home" && -d "$ndk_home" ]]; then
    echo "$ndk_home"
    return 0
  fi

  local sdk_root="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
  if [[ -n "$sdk_root" ]]; then
    local latest
    latest="$(pick_latest_ndk "$sdk_root/ndk")" || true
    if [[ -n "$latest" ]]; then
      echo "$sdk_root/ndk/$latest"
      return 0
    fi
  fi

  local mac_sdk="$HOME/Library/Android/sdk"
  local linux_sdk="$HOME/Android/Sdk"
  local latest

  latest="$(pick_latest_ndk "$mac_sdk/ndk")" || true
  if [[ -n "$latest" ]]; then
    echo "$mac_sdk/ndk/$latest"
    return 0
  fi

  latest="$(pick_latest_ndk "$linux_sdk/ndk")" || true
  if [[ -n "$latest" ]]; then
    echo "$linux_sdk/ndk/$latest"
    return 0
  fi

  echo "unable to locate Android NDK. Set XFORGE_ANDROID_NDK, ANDROID_NDK_HOME, or ANDROID_SDK_ROOT." >&2
  return 1
}

resolve_host_tag() {
  local toolchains="$1/toolchains/llvm/prebuilt"
  local tag
  for tag in darwin-x86_64 darwin-arm64 linux-x86_64 windows-x86_64; do
    if [[ -d "$toolchains/$tag/bin" ]]; then
      echo "$tag"
      return 0
    fi
  done
  echo "unable to find NDK prebuilt host toolchain under $toolchains" >&2
  return 1
}

resolve_linker_binary() {
  case "$target" in
    aarch64-linux-android) echo "aarch64-linux-android${api}-clang" ;;
    armv7-linux-androideabi) echo "armv7a-linux-androideabi${api}-clang" ;;
    x86_64-linux-android) echo "x86_64-linux-android${api}-clang" ;;
    *)
      echo "unsupported Android target '$target'" >&2
      return 1
      ;;
  esac
}

ndk_root="$(resolve_ndk_root)"
host_tag="$(resolve_host_tag "$ndk_root")"
linker_bin="$(resolve_linker_binary)"
linker="$ndk_root/toolchains/llvm/prebuilt/$host_tag/bin/$linker_bin"

if [[ ! -f "$linker" ]]; then
  echo "Android linker not found: $linker" >&2
  echo "Check XFORGE_ANDROID_API (current: $api) and installed NDK version." >&2
  exit 1
fi

exec "$linker" "$@"
