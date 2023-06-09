#!/bin/sh

populate_dir() {
    mkdir -p "$1"
    head -c 1000000 < /dev/urandom > "$1/1.bin"
    head -c 5000000 < /dev/urandom > "$1/2.bin"
    head -c 10000000 < /dev/urandom > "$1/3.bin"
}

BIN_DIR="$(mktemp -d)"
CONFIG_FILE="${BIN_DIR}/config.yml"
KERNEL="$(uname -s)"
curl -L "https://github.com/hacdias/webdav/releases/download/v4.1.0/$(echo $KERNEL | awk '{print tolower($0)}')-amd64-webdav.tar.gz" | tar xvz -C "${BIN_DIR}"

cat > "${CONFIG_FILE}" <<EOF
address: 0.0.0.0
port: 8000
auth: true

scope: .
modify: true
rules: []

users:
- username: test
  password: test
EOF

WEBDAV_DIR="$(mktemp -d)"
populate_dir "${WEBDAV_DIR}"
populate_dir "${WEBDAV_DIR}/a"
populate_dir "${WEBDAV_DIR}/a/a"
populate_dir "${WEBDAV_DIR}/a/b"
populate_dir "${WEBDAV_DIR}/a/c"
printf "WebDAV root: %s\n" "${WEBDAV_DIR}"

cd "${WEBDAV_DIR}" || false
exec "${BIN_DIR}/webdav" --config "${CONFIG_FILE}"
