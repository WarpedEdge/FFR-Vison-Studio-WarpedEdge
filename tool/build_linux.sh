#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="ffr-vision-studio-linux-builder:3.47.5"

podman build --tag "$image" --file "$repo_dir/tool/linux/Containerfile" "$repo_dir/tool/linux"
podman run --rm \
  --security-opt label=disable \
  --userns=keep-id \
  --volume "$repo_dir:/workspace" \
  --workdir /workspace \
  "$image" \
  bash -lc 'flutter pub get && flutter build linux --release "$@"' -- "$@"

printf '%s\n' "Linux bundle: $repo_dir/build/linux/x64/release/bundle"
