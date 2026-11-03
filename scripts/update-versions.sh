#!/usr/bin/env bash
# Usage: scripts/update-versions.sh yt-dlp <tag>
#        scripts/update-versions.sh bgutil <tag>
# Rewrites nix/versions.json with the new version and its Nix source hash.
set -euo pipefail
cd "$(dirname "$0")/.."

nix="nix --extra-experimental-features nix-command --extra-experimental-features flakes"
what="${1:?usage: $0 yt-dlp|bgutil <tag>}"
tag="${2:?usage: $0 yt-dlp|bgutil <tag>}"

case "$what" in
  yt-dlp)
    key=ytDlp
    # Matches fetchFromGitHub { tag = ...; } in nixpkgs.
    hash=$($nix flake prefetch --json "github:yt-dlp/yt-dlp/${tag}" | jq -r .hash)
    ;;
  bgutil)
    key=bgutil
    hash=$($nix store prefetch-file --json \
      "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/${tag}/bgutil-ytdlp-pot-provider.zip" \
      | jq -r .hash)
    ;;
  *) echo "unknown target: $what" >&2; exit 2 ;;
esac

tmp=$(mktemp)
jq --arg k "$key" --arg v "$tag" --arg h "$hash" \
  '.[$k] = {version: $v, hash: $h}' nix/versions.json > "$tmp"
mv "$tmp" nix/versions.json
echo "$key -> $tag ($hash)"
