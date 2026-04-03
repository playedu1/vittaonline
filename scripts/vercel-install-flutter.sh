#!/bin/sh
set -eu

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

echo "[install] ensuring curl + xz are available"
if need_cmd apt-get; then
  apt-get update -y
  apt-get install -y curl xz-utils
elif need_cmd dnf; then
  dnf install -y curl xz
elif need_cmd microdnf; then
  microdnf install -y curl xz
elif need_cmd yum; then
  yum install -y curl xz
else
  echo "[install] no supported package manager found (need curl + xz)" >&2
  exit 1
fi

FLUTTER_VERSION="3.38.4"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"

if [ -d "flutter" ]; then
  echo "[install] flutter/ already exists, skipping download"
  exit 0
fi

echo "[install] downloading Flutter ${FLUTTER_VERSION}"
curl -sSL "$FLUTTER_URL" -o flutter.tar.xz
tar -xJf flutter.tar.xz
