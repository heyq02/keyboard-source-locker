#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${1:-release}"
PRODUCT="KeyboardSourceLockerApp"
APP_NAME="KeyboardSourceLocker"
BUILD_DIR="${ROOT_DIR}/.build/${CONFIG}"
DIST_DIR="${ROOT_DIR}/dist"
APP_DIR="${DIST_DIR}/${APP_NAME}.app"

cd "${ROOT_DIR}"

echo "==> Reading version from package.json via Swift"
swift build -c "${CONFIG}" --product VersionTool
VERSION="$(swift run -c "${CONFIG}" VersionTool)"
if [[ -z "${VERSION}" ]]; then
  echo "error: VersionTool returned empty version" >&2
  exit 1
fi
BUILD_NUMBER="${BUILD_NUMBER:-$(git -C "${ROOT_DIR}" rev-list --count HEAD 2>/dev/null || echo 1)}"

echo "==> Building ${PRODUCT} (${CONFIG}) version ${VERSION} (${BUILD_NUMBER})"
swift build -c "${CONFIG}" --product "${PRODUCT}"

BINARY="${BUILD_DIR}/${PRODUCT}"
if [[ ! -x "${BINARY}" ]]; then
  echo "error: expected binary at ${BINARY}" >&2
  exit 1
fi

echo "==> Packaging ${APP_NAME}.app"
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

cp "${BINARY}" "${APP_DIR}/Contents/MacOS/${PRODUCT}"
cp "${ROOT_DIR}/Resources/Info.plist" "${APP_DIR}/Contents/Info.plist"
# Ship package.json so the app can read the same version source at runtime.
cp "${ROOT_DIR}/package.json" "${APP_DIR}/Contents/Resources/package.json"
chmod +x "${APP_DIR}/Contents/MacOS/${PRODUCT}"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "${APP_DIR}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" "${APP_DIR}/Contents/Info.plist"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "${APP_DIR}"
fi

echo "==> Packaged at ${APP_DIR} (version ${VERSION})"
ls -la "${APP_DIR}/Contents/MacOS"
ls -la "${APP_DIR}/Contents/Resources"
