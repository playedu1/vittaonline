#!/bin/sh
set -eu

export PATH="$PWD/flutter/bin:$PATH"

echo "[build] flutter --version"
flutter --version

echo "[build] flutter pub get"
flutter config --no-analytics >/dev/null 2>&1 || true
flutter pub get

echo "[build] flutter build web --release"
flutter build web --release
