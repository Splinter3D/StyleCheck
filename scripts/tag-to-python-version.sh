#!/usr/bin/env bash
set -euo pipefail

tag="${1:-}"

if [[ -z "$tag" ]]; then
  echo "Usage: $0 <tag>" >&2
  exit 1
fi

if [[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)-rc\.([0-9]+)$ ]]; then
  echo "${BASH_REMATCH[1]}rc${BASH_REMATCH[2]}"
  exit 0
fi

if [[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  echo "${BASH_REMATCH[1]}"
  exit 0
fi

echo "Unsupported tag format: $tag" >&2
exit 1
