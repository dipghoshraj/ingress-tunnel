#!/bin/bash
# =============================================================================
# Agni Seeder — Setup Script
# Downloads the seeder binary, installs it system-wide, creates the service
# working directory, writes a seeder-config.yaml skeleton, and generates TLS
# certificates.  The seeder is the backbone of the stack — run this FIRST,
# before setting up agni-router or agni-nova.
# Run as root (or with sudo).
# =============================================================================
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
BINARY_URL="https://github.com/odio4u/memstore/releases/download/v0.1.0-beta/seeder-linux-amd64"
BINARY_NAME="seeder"
INSTALL_PATH="/usr/local/bin/${BINARY_NAME}"
SERVICE_DIR="/opt/agni-seeder"
CONFIG_FILE="${SERVICE_DIR}/seeder-config.yaml"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[agni-seeder]${NC} $*"; }
warn()    { echo -e "${YELLOW}[agni-seeder]${NC} $*"; }
error()   { echo -e "${RED}[agni-seeder] ERROR:${NC} $*" >&2; }
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
heading "Step 2 — Downloading seeder binary"
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

# verify it runs
if ! "${INSTALL_PATH}" --help &>/dev/null && ! "${INSTALL_PATH}" version &>/dev/null; then
  warn "Binary executed but returned non-zero (may be normal if no --help flag). Continuing."
fi

# ── 3. Write config skeleton ──────────────────────────────────────────────────
heading "Step 3 — Writing seeder-config.yaml skeleton"
if [[ -f "${CONFIG_FILE}" ]]; then
  warn "Config file already exists at ${CONFIG_FILE} — skipping overwrite."
  warn "Delete it manually and re-run if you want a fresh skeleton."
else
  cat > "${CONFIG_FILE}" << 'EOF'
version: v1

Seeder:
  # Friendly name also used as the Common Name (CN) in the generated TLS cert.
  # Other services reference this cert by its SHA-256 fingerprint.
  name: "seedercert"

  # DNS name placed in the TLS certificate SAN.
  # Set to the public domain or IP hostname of this server.
  dns: "YOUR_SEEDER_DNS_OR_HOSTNAME"

  # IP address placed in the TLS certificate SAN.
  # Set to the public (or LAN) IP that agents / router / nova will reach.
  ip: "YOUR_SEEDER_IP"

  # Port the seeder gRPC / registration service listens on.
  # Agents, router, and nova connect here.
  port: 8080

  # Port for the seeder viewer / HTTP dashboard (optional, internal use).
  viewer: 9000

  # Routing region tag — match this across all services in the same cluster.
  region: "global"
EOF
  info "Config skeleton written to ${CONFIG_FILE}"
fi

# ── 4. Prompt user to edit config ─────────────────────────────────────────────
heading "Step 4 — Edit the config"
echo ""
echo "  Open and fill in all placeholder values before continuing:"
echo ""
echo "    nano ${CONFIG_FILE}"
echo ""
echo "  Fields to update:"
echo "    dns    → public DNS hostname of this server (e.g. seeder.example.com)"
echo "    ip     → public or LAN IP address of this server"
echo "    port   → leave as 8080 unless you need a different port"
echo "    viewer → leave as 9000 unless you need a different port"
echo ""
read -rp "Press ENTER once you have saved the config to generate TLS certificates…"

# ── 5. Generate TLS certificates ──────────────────────────────────────────────
heading "Step 5 — Generating TLS certificates"
cd "${SERVICE_DIR}"
"${INSTALL_PATH}" -gen-cert
info "Certificates written to ${SERVICE_DIR}/server.pem and ${SERVICE_DIR}/server-key.pem"

# ── 6. Print fingerprint extraction instructions ──────────────────────────────
heading "Step 6 — Capture the seeder TLS fingerprint"
echo ""
echo "  Every other service (agni-router, agni-nova, agni-agent) authenticates"
echo "  the seeder using its SHA-256 TLS certificate fingerprint."
echo ""
echo "  The fingerprint is printed in the seeder logs at startup."
echo "  You can also extract it from the cert file once generated:"
echo ""
echo "    openssl x509 -in ${SERVICE_DIR}/server.pem -fingerprint -sha256 -noout \\"
echo "      | cut -d= -f2 | tr -d ':' | tr '[:upper:]' '[:lower:]'"
echo ""
echo "  Copy that hex string into the 'fingureprint' field in:"
echo "    • /opt/agni-router/agni-config.yaml  (Router.Seeder.fingureprint)"
echo "    • /opt/agni-nova/agni-config.yaml    (Nova.Seeder.fingureprint)"
echo "    • Agent's agni-config.yaml           (Agent.Seeder.fingureprint)"
echo ""

# ── 7. Final next steps ───────────────────────────────────────────────────────
heading "Setup complete!"
echo ""
echo "  Start the seeder in the background:"
echo ""
echo "    sudo bash $(dirname "$0")/run.sh"
echo ""
echo "  Logs will be written to: ${SERVICE_DIR}/agni-seeder.log"
echo "  PID file will be at    : ${SERVICE_DIR}/agni-seeder.pid"
echo ""
echo "  NOTE: Start the seeder BEFORE agni-router and agni-nova."
echo ""
