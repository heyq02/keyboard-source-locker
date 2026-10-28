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

echo "==> Building ${PRODUCT} (${CONFIG})"
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
chmod +x "${APP_DIR}/Contents/MacOS/${PRODUCT}"

# Ad-hoc sign so Gatekeeper is less noisy on local CI artifacts.
if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "${APP_DIR}"
fi

echo "==> Packaged at ${APP_DIR}"
ls -la "${APP_DIR}/Contents/MacOS"
