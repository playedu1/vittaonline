#!/bin/sh
set -eu

FLUTTER_BIN="$PWD/flutter/bin/flutter"

echo "[build] pwd: $PWD"
echo "[build] whoami: $(whoami 2>/dev/null || echo unknown)"
echo "[build] uid: $(id -u 2>/dev/null || echo unknown)"

if [ ! -f "$FLUTTER_BIN" ]; then
  echo "[build] flutter binary not found at: $FLUTTER_BIN" >&2
  echo "[build] install step likely failed to extract Flutter into ./flutter" >&2
  exit 1
fi

chmod +x "$FLUTTER_BIN" 2>/dev/null || true

if command -v git >/dev/null 2>&1; then
  # Flutter uses git internally; Vercel builders can trigger git's "dubious ownership" protection.
  if command -v mktemp >/dev/null 2>&1; then
    export GIT_CONFIG_GLOBAL="$(mktemp)"
  else
    export GIT_CONFIG_GLOBAL="$PWD/.gitconfig"
  fi

  git config --global --add safe.directory "$PWD" || true
  git config --global --add safe.directory "$PWD/flutter" || true
else
  echo "[build] git not found; flutter may fail with exit 128" >&2
fi

echo "[build] flutter --version"
"$FLUTTER_BIN" --version

echo "[build] flutter pub get"
"$FLUTTER_BIN" config --no-analytics >/dev/null 2>&1 || true
"$FLUTTER_BIN" config --enable-web >/dev/null 2>&1 || true
"$FLUTTER_BIN" pub get

echo "[build] flutter build web --release"
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "[build] missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables" >&2
  echo "[build] configure them in Vercel Project Settings > Environment Variables" >&2
  exit 1
fi

DEFINES_FILE="$PWD/.dart-defines.vercel.json"
trap 'rm -f "$DEFINES_FILE"' EXIT
cat >"$DEFINES_FILE" <<EOF
{
  "SUPABASE_URL": "${SUPABASE_URL}",
  "SUPABASE_ANON_KEY": "${SUPABASE_ANON_KEY}"
}
EOF

"$FLUTTER_BIN" build web --release --dart-define-from-file="$DEFINES_FILE"
