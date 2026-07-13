#!/usr/bin/env bash
# Runs the DBSC demo ON a Meta devserver behind Secure Web Apps (HTTPS on a 442xx port using
# the box's own host cert). This script is meant to be executed on the devserver — deploy.sh
# rsyncs the repo up and then runs it here. See README §10.
set -euo pipefail
cd "$(dirname "$0")"

# Cargo needs the fwdproxy to reach crates.io on a devserver (else the build hangs).
feature install ttls_fwdproxy >/dev/null 2>&1 || echo ">> (couldn't auto-install ttls_fwdproxy; if cargo hangs fetching crates, run: feature install ttls_fwdproxy)"

# Ensure a Rust toolchain.
if ! command -v cargo >/dev/null 2>&1; then
  echo ">> Installing Rust (rustup)…"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env" 2>/dev/null || true

# Point the app at the host cert + a 442xx HTTPS port, bound on IPv6 (see README §10 gotchas).
H="$(hostname)"; S="${H%%.*}"
export DBSC_BIND="[::]:44200"
export DBSC_TLS_CERT="/etc/pki/tls/certs/${H}.crt"
export DBSC_TLS_KEY="/etc/pki/tls/certs/${H}.key"
export DBSC_ORIGIN="https://${S}.fbinfra.net:44200"
export DBSC_HOST="${S}.fbinfra.net"

echo ">> DBSC_ORIGIN = $DBSC_ORIGIN"
echo ">> Open that URL in Chrome (macOS first, then Windows). Ctrl-C to stop."
echo ">> If it can't read $DBSC_TLS_KEY (permission denied), the host key may be root-only —"
echo ">>   copy it to a readable path (with sudo) and set DBSC_TLS_KEY/CERT accordingly."
exec cargo run
