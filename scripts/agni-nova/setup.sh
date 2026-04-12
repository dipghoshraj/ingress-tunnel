#!/bin/bash
# =============================================================================
# Agni Nova — Setup Script
# Downloads the agni-nova-proxy binary, installs it system-wide, creates the
# service working directory, and writes a config skeleton.
# Nova does not need TLS cert generation (it merely peeks SNI and forwards).
# Run as root (or with sudo).
# =============================================================================
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
BINARY_URL="https://github.com/odio4u/agni-tunnels/releases/download/v0.0.1/agni-nova"
BINARY_NAME="agni-nova"
INSTALL_PATH="/usr/local/bin/${BINARY_NAME}"
SERVICE_DIR="/opt/agni-nova"
CONFIG_FILE="${SERVICE_DIR}/agni-config.yaml"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[agni-nova]${NC} $*"; }
warn()    { echo -e "${YELLOW}[agni-nova]${NC} $*"; }
error()   { echo -e "${RED}[agni-nova] ERROR:${NC} $*" >&2; }
heading() { echo -e "\n${BOLD}$*${NC}"; }

# ── Root check ────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root or with sudo."
  exit 1
fi

# ── 1. Create service directory ───────────────────────────────────────────────
heading "Step 1 — Creating service directory"
mkdir -p "${SERVICE_DIR}"
info "Service directory: ${SERVICE_DIR}"

# ── 2. Download binary ────────────────────────────────────────────────────────
heading "Step 2 — Downloading agni-nova binary"
if command -v curl &>/dev/null; then
  curl -fsSL -o "${INSTALL_PATH}" "${BINARY_URL}"
elif command -v wget &>/dev/null; then
  wget -q -O "${INSTALL_PATH}" "${BINARY_URL}"
else
  error "Neither curl nor wget is available. Install one and re-run."
  exit 1
fi

chmod +x "${INSTALL_PATH}"
info "Binary installed at ${INSTALL_PATH}"

# ── 3. Write config skeleton ──────────────────────────────────────────────────
heading "Step 3 — Writing config skeleton"
if [[ -f "${CONFIG_FILE}" ]]; then
  warn "Config file already exists at ${CONFIG_FILE} — skipping overwrite."
  warn "Delete it manually and re-run if you want a fresh skeleton."
else
  cat > "${CONFIG_FILE}" << 'EOF'
version: v1

Nova:
  # Friendly name used in logs.
  name: "agni-Nova"

  # TCP port Nova listens on for incoming client connections.
  # Nova peeks the TLS SNI, looks up the target router in the seeder, and
  # forwards the raw stream to the correct agni-router instance.
  port: "9001"

  Seeder:
    # Host:port of the seeder (mem-sdk) service.
    address: "YOUR_SEEDER_HOST:PORT"

    # SHA-256 hex fingerprint of the seeder's TLS certificate.
    # Retrieve with: openssl s_client -connect <host>:<port> </dev/null 2>/dev/null \
    #   | openssl x509 -fingerprint -sha256 -noout | cut -d= -f2 | tr -d ':'
    fingureprint: "YOUR_SEEDER_TLS_FINGERPRINT_HEX"
EOF
  info "Config skeleton written to ${CONFIG_FILE}"
fi

# ── 4. Prompt user to edit config ─────────────────────────────────────────────
heading "Step 4 — Edit the config"
echo ""
echo "  Open and fill in all placeholder values:"
echo ""
echo "    nano ${CONFIG_FILE}"
echo ""
echo "  Fields to update:"
echo "    port                 → TCP port Nova listens on (default 9001)"
echo "    Seeder.address       → seeder host:port"
echo "    Seeder.fingureprint  → SHA-256 hex fingerprint of seeder TLS cert"
echo ""

# ── 5. Print next steps ───────────────────────────────────────────────────────
heading "Setup complete!"
echo ""
echo "  After editing the config, run agni-nova in the background:"
echo ""
echo "    sudo bash $(dirname "$0")/run.sh"
echo ""
echo "  Logs will be written to: ${SERVICE_DIR}/agni-nova.log"
echo "  PID file will be at    : ${SERVICE_DIR}/agni-nova.pid"
echo ""
