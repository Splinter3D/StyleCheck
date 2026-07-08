#!/usr/bin/env bash
set -euo pipefail

FIX=false
TAG=""

for arg in "$@"; do
  case "$arg" in
    -h | --help)
        echo "Usage: $0 [--fix] [TAG]"
        echo "  --fix: Check versions and attempt to fix mismatches by aligning all version sources to the SCM version."
        echo "  TAG: Optional. If provided, uses this tag as the SCM version for comparison. Otherwise, uses the latest git tag."
        exit 0
        ;;
    --fix)
        FIX=true
        ;;
    *)
        TAG="$arg"
        ;;
  esac
done

if ! command -v git &> /dev/null; then
    echo "git is required but not found. Please install git and try again."
    exit 1
fi

die() { echo "ERROR: $*" >&2; exit 1; }

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

getSCMVersion() {
    if [[ -n "$TAG" ]]; then
        if [[ "$TAG" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
            TAG="v$TAG"
            echo "Normalized tag to $TAG (prefixed 'v')" >&2
        fi

        if ! [[ "$TAG" =~ ^v[0-9]+(\.[0-9]+)*(-rc\.[0-9]+)?$ ]]; then
            die "Invalid tag format: '$TAG'. Expected format like 'v1.2.3' or 'v1.2.3-rc.1'."
        fi
        "$SCRIPTS_DIR/tag-to-python-version.sh" "$TAG"
        return
    fi

    latest="$(git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -n1)"
    if [[ -z "$latest" ]]; then
        latest="v0.0.0"
    fi
    "$SCRIPTS_DIR/tag-to-python-version.sh" "$latest"
}

getPyProjectVersion() {
    python3 -c "
import tomllib, sys
with open('pyproject.toml', 'rb') as f:
    data = tomllib.load(f)
print(data['project']['version'])
"
}

setPyProjectVersion() {
    local new_version="$1"
    python3 -c "
import tomlkit, sys
with open('pyproject.toml', 'r') as f:
    doc = tomlkit.load(f)
doc['project']['version'] = '$new_version'
with open('pyproject.toml', 'w') as f:
    tomlkit.dump(doc, f)
"
}

SCM_V=$(getSCMVersion)
PYPROJECT_V=$(getPyProjectVersion)

if [[ "$PYPROJECT_V" != "$SCM_V" ]]; then
    echo "Version mismatch detected!"
    echo "  PyProject: $PYPROJECT_V"
    echo "  SCM: $SCM_V"

    if [[ "$FIX" == true ]]; then
        echo "Attempting to fix version mismatches..."
        setPyProjectVersion "$SCM_V"

        # Verify the fix
        NEW_V=$(getPyProjectVersion)
        if [[ "$NEW_V" != "$SCM_V" ]]; then
            echo "Failed to fix version mismatches. Please check the files manually."
            exit 1
        else
            echo "All versions are now consistent with SCM version: $SCM_V"
            exit 0
        fi
    else
        exit 1
    fi
fi

echo "All versions are consistent: $SCM_V"
exit 0
