#!/usr/bin/env bash
# build.sh — Build MetaWear-SDK-Cpp
#
# Usage:
#   ./build.sh [release|debug] [--clean]
#
# Examples:
#   ./build.sh                  # release build
#   ./build.sh debug            # debug build
#   ./build.sh release --clean  # clean then release build

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIGURATION="${1:-release}"
CLEAN=0

# Parse flags
for arg in "$@"; do
    case "$arg" in
        release|debug) CONFIGURATION="$arg" ;;
        --clean)       CLEAN=1 ;;
    esac
done

if [[ "$CONFIGURATION" != "release" && "$CONFIGURATION" != "debug" ]]; then
    echo "ERROR: CONFIGURATION must be 'release' or 'debug', got '$CONFIGURATION'"
    exit 1
fi

cd "$REPO_DIR"

if [[ "$CLEAN" -eq 1 ]]; then
    echo "==> Cleaning previous build artifacts..."
    make clean CONFIGURATION="$CONFIGURATION"
fi

echo "==> Building MetaWear-SDK-Cpp [CONFIGURATION=$CONFIGURATION]..."
make build CONFIGURATION="$CONFIGURATION"

echo ""
echo "==> Build succeeded."

# Print the location of the output library
KERNEL="$(uname -s)"
MACHINE_RAW="$(uname -m)"
case "$MACHINE_RAW" in
    x86_64|amd64) MACHINE=x64 ;;
    aarch64|arm64) MACHINE=aarch64 ;;
    arm*)          MACHINE=arm ;;
    *)             MACHINE=x86 ;;
esac

APP_NAME="metawear"
[[ "$CONFIGURATION" == "debug" ]] && APP_NAME="${APP_NAME}_d"

if [[ "$KERNEL" == "Darwin" ]]; then
    EXT="dylib"
else
    EXT="so"
fi

VERSION="$(grep '^VERSION=' project_version.mk | cut -d= -f2)"
DIST_DIR="dist/$CONFIGURATION/lib/$MACHINE"
LIB="$DIST_DIR/lib${APP_NAME}.${EXT}.${VERSION}"

echo ""
echo "Output library: $REPO_DIR/$LIB"
ls -lh "$REPO_DIR/$DIST_DIR/"

# Fix install name so dyld can locate the library via @rpath
if [[ "$KERNEL" == "Darwin" ]]; then
    SONAME="lib${APP_NAME}.${EXT}.$(echo "$VERSION" | cut -d. -f1)"
    DYLIB="$REPO_DIR/$DIST_DIR/$SONAME"
    if [[ -f "$DYLIB" ]]; then
        echo ""
        echo "==> Fixing install name: @rpath/$SONAME"
        install_name_tool -id "@rpath/$SONAME" "$DYLIB"
    fi
fi
