#!/bin/sh
set -eu

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

echo "[install] checking prerequisites (curl + tar with xz support)"
if need_cmd curl && need_cmd tar; then
  echo "[install] curl: $(command -v curl)"
  echo "[install] tar:  $(command -v tar)"
else
  echo "[install] missing required commands (need curl + tar)" >&2
  exit 1
fi

if need_cmd xz; then
  echo "[install] xz:   $(command -v xz)"
else
  echo "[install] xz not found; will try tar -xJf anyway"
fi

# Vercel builders often run as a non-root user; package installs will fail.
# Only attempt to install deps if we are root AND a package manager exists.
if [ "$(id -u 2>/dev/null || echo 9999)" = "0" ]; then
  if need_cmd xz; then
    echo "[install] deps already present"
  else
    echo "[install] attempting to install xz (running as root)"
    if need_cmd apt-get; then
      apt-get update -y
      apt-get install -y xz-utils
    elif need_cmd dnf; then
      dnf install -y xz
    elif need_cmd microdnf; then
      microdnf install -y xz
    elif need_cmd yum; then
      yum install -y xz
    else
      echo "[install] no supported package manager found (need xz)" >&2
      exit 1
    fi
  fi
else
  echo "[install] non-root build user; skipping package installs"
fi

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.8}"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL_PRIMARY="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"
FLUTTER_URL_MIRROR="https://storage.flutter-io.cn/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"

if [ -d "flutter" ]; then
  echo "[install] flutter/ already exists, skipping download"
  exit 0
fi

echo "[install] downloading Flutter ${FLUTTER_VERSION}"
echo "[install] trying: ${FLUTTER_URL_PRIMARY}"
if ! curl -fSsL "$FLUTTER_URL_PRIMARY" -o flutter.tar.xz; then
  echo "[install] primary URL failed, trying mirror"
  echo "[install] trying: ${FLUTTER_URL_MIRROR}"
  curl -fSsL "$FLUTTER_URL_MIRROR" -o flutter.tar.xz
fi
tar -xJf flutter.tar.xz
