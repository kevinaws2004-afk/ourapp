#!/usr/bin/env bash
# Creates the Google Play upload key and android/key.properties, once.
#
#   bash tool/make_upload_key.sh
#
# It asks for a password (typed by you, never stored in the repo). Both files
# are git-ignored. BACK UP the .jks file and the password somewhere safe
# (password manager + a copy off this computer): without them you can't
# publish updates. With Play App Signing (the default for new apps) Google
# keeps the real app signing key; this one only uploads, and Play support can
# reset it if lost — but that takes days.
set -euo pipefail
cd "$(dirname "$0")/.."

KEYSTORE="$HOME/daycraft-upload.jks"
PROPS="android/key.properties"

if [[ -f "$PROPS" ]]; then
  echo "✗ $PROPS already exists. Not overwriting an existing key."
  exit 1
fi
if [[ -f "$KEYSTORE" ]]; then
  echo "✗ $KEYSTORE already exists. Move it away first if you really want a new key."
  exit 1
fi
if ! command -v keytool >/dev/null; then
  # Android Studio ships a JDK.
  JBR="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin"
  [[ -x "$JBR/keytool" ]] && PATH="$JBR:$PATH"
fi
command -v keytool >/dev/null || { echo "✗ keytool not found (install a JDK)."; exit 1; }

read -r -s -p "Choose a keystore password (6+ characters): " PASS; echo
read -r -s -p "Type it again: " PASS2; echo
[[ "$PASS" == "$PASS2" ]] || { echo "✗ Passwords differ."; exit 1; }
[[ ${#PASS} -ge 6 ]] || { echo "✗ Too short."; exit 1; }
read -r -p "Your name (for the certificate): " CN

keytool -genkeypair -v \
  -keystore "$KEYSTORE" -storetype JKS \
  -alias upload -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass "$PASS" -keypass "$PASS" \
  -dname "CN=${CN:-DayCraft}, O=DayCraft"

cat > "$PROPS" <<EOF
storePassword=$PASS
keyPassword=$PASS
keyAlias=upload
storeFile=$KEYSTORE
EOF
chmod 600 "$PROPS" "$KEYSTORE"

echo
echo "✓ Upload key: $KEYSTORE"
echo "✓ $PROPS written (git-ignored)."
echo
echo "NOW: back up $KEYSTORE and the password somewhere safe."
echo "Then: bash tool/release_check.sh && flutter build appbundle --release"
