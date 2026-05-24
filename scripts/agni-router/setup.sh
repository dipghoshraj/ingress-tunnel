#!/bin/bash
# =============================================================================
# Agni Router — Setup Script
# Downloads the agni-router binary, installs it system-wide, creates the
# service working directory, writes a config skeleton, and generates TLS certs.
# Run as root (or with sudo).
# =============================================================================
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
BINARY_URL="https://github.com/odio4u/agni-tunnels/releases/download/v0.0.1/agni-router"
BINARY_NAME="agni-router"
INSTALL_PATH="/usr/local/bin/${BINARY_NAME}"
SERVICE_DIR="/opt/agni-router"
CONFIG_FILE="${SERVICE_DIR}/agni-config.yaml"
CERTS_DIR="${SERVICE_DIR}/certs"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[agni-router]${NC} $*"; }
warn()    { echo -e "${YELLOW}[agni-router]${NC} $*"; }
error()   { echo -e "${RED}[agni-router] ERROR:${NC} $*" >&2; }
heading() { echo -e "\n${BOLD}$*${NC}"; }

# ── Root check ────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root or with sudo."
  exit 1
fi

# ── 1. Create directories ─────────────────────────────────────────────────────
heading "Step 1 — Creating service directory"
mkdir -p "${CERTS_DIR}"
info "Service directory: ${SERVICE_DIR}"
info "Certs directory  : ${CERTS_DIR}"

# ── 2. Download binary ────────────────────────────────────────────────────────
heading "Step 2 — Downloading agni-router binary"
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

# ── 4. Prompt user to edit config ─────────────────────────────────────────────
heading "Step 4 — Edit the config"
echo ""
echo "  Open and fill in all placeholder values before continuing:"
echo ""
echo "    nano ${CONFIG_FILE}"
echo ""
echo "  Fields to update:"
echo "    router_ip     → public IP of this server"
echo "    dns           → domain or IP for the TLS cert (e.g. router.example.com)"
echo "    Seeder.address       → seeder host:port"
echo "    Seeder.fingureprint  → SHA-256 hex fingerprint of seeder TLS cert"
echo ""
read -rp "Press ENTER once you have saved the config to generate TLS certificates…"

# ── 5. Generate TLS certificates ──────────────────────────────────────────────
heading "Step 5 — Generating TLS certificates"
cd "${SERVICE_DIR}"
"${INSTALL_PATH}" gen-certs
# Move certificates to the certs subdirectory
if [[ -f "server.pem" ]] && [[ -f "server-key.pem" ]]; then
  mv server.pem "${CERTS_DIR}/"
  mv server-key.pem "${CERTS_DIR}/"
  info "Certificates moved to ${CERTS_DIR}/"
else
  error "Certificate generation failed: server.pem or server-key.pem not found"
  exit 1
fi

# ── 6. Print next steps ───────────────────────────────────────────────────────
heading "Setup complete!"
echo ""
echo "  Run agni-router in the background:"
echo ""
echo "    sudo bash $(dirname "$0")/run.sh"
echo ""
echo "  Logs will be written to: ${SERVICE_DIR}/agni-router.log"
echo "  PID file will be at    : ${SERVICE_DIR}/agni-router.pid"
echo ""
