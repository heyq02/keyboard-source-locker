#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${1:-release}"
PRODUCT="KeyboardSourceLockerApp"
APP_NAME="KeyboardSourceLocker"
BUILD_DIR="${ROOT_DIR}/.build/${CONFIG}"
DIST_DIR="${ROOT_DIR}/dist"
APP_DIR="${DIST_DIR}/${APP_NAME}.app"

# Prefer explicit VERSION, then git tag (v1.2.3 → 1.2.3), then Info.plist default.
VERSION="${VERSION:-}"
if [[ -z "${VERSION}" ]]; then
  if GIT_TAG="$(git -C "${ROOT_DIR}" describe --tags --exact-match 2>/dev/null || true)"; then
    if [[ "${GIT_TAG}" =~ ^v ]]; then
      VERSION="${GIT_TAG#v}"
    fi
  fi
fi
VERSION="${VERSION:-1.0.0}"
BUILD_NUMBER="${BUILD_NUMBER:-$(git -C "${ROOT_DIR}" rev-list --count HEAD 2>/dev/null || echo 1)}"

cd "${ROOT_DIR}"

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
chmod +x "${APP_DIR}/Contents/MacOS/${PRODUCT}"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "${APP_DIR}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" "${APP_DIR}/Contents/Info.plist"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "${APP_DIR}"
fi

echo "==> Packaged at ${APP_DIR}"
ls -la "${APP_DIR}/Contents/MacOS"
