#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
exec "$script_dir/xforge-android-linker.sh" x86_64-linux-android "$@"
