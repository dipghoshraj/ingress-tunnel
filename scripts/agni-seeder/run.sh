#!/bin/bash
# =============================================================================
# Agni Seeder — Run Script
# Starts the seeder as a background (nohup) process.
# Must be run as root (or with sudo).
# The service always executes inside SERVICE_DIR so that seeder-config.yaml
# and any generated cert files are found correctly.
# =============================================================================
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
BINARY_NAME="seeder"
INSTALL_PATH="/usr/local/bin/${BINARY_NAME}"
SERVICE_DIR="/opt/agni-seeder"
LOG_FILE="${SERVICE_DIR}/agni-seeder.log"
PID_FILE="${SERVICE_DIR}/agni-seeder.pid"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[agni-seeder]${NC} $*"; }
warn()  { echo -e "${YELLOW}[agni-seeder]${NC} $*"; }
error() { echo -e "${RED}[agni-seeder] ERROR:${NC} $*" >&2; }

# ── Pre-flight checks ─────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root or with sudo."
  exit 1
fi

if [[ ! -x "${INSTALL_PATH}" ]]; then
  error "Binary not found at ${INSTALL_PATH}. Run setup.sh first."
  exit 1
fi

if [[ ! -f "${SERVICE_DIR}/seeder-config.yaml" ]]; then
  error "Config not found at ${SERVICE_DIR}/seeder-config.yaml. Run setup.sh first."
  exit 1
fi

# ── Already running? ──────────────────────────────────────────────────────────
if [[ -f "${PID_FILE}" ]]; then
  OLD_PID=$(cat "${PID_FILE}")
  if kill -0 "${OLD_PID}" 2>/dev/null; then
    warn "seeder is already running (PID ${OLD_PID})."
    warn "Stop it first:  kill ${OLD_PID}"
    exit 1
  else
    warn "Stale PID file found (PID ${OLD_PID} is not running). Removing."
    rm -f "${PID_FILE}"
  fi
fi

# ── Start service ─────────────────────────────────────────────────────────────
info "Starting agni-seeder…"
info "  Working dir : ${SERVICE_DIR}"
info "  Log file    : ${LOG_FILE}"
info "  PID file    : ${PID_FILE}"

cd "${SERVICE_DIR}"
nohup "${INSTALL_PATH}" >> "${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"

sleep 1   # brief pause so any immediate crash shows in the log

if kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  info "agni-seeder started successfully (PID $(cat "${PID_FILE}"))."
else
  error "agni-seeder exited immediately. Check the log for details:"
  error "  tail -n 40 ${LOG_FILE}"
  rm -f "${PID_FILE}"
  exit 1
fi

# ── Print fingerprint reminder ────────────────────────────────────────────────
echo ""
echo "  The seeder TLS fingerprint is printed in the startup log."
echo "  Run the following to extract it:"
echo ""
echo "    grep -i fingerprint ${LOG_FILE} | tail -1"
echo ""
  echo "  Or extract directly from the cert file (generated in ${SERVICE_DIR}):"
echo ""
echo "    openssl x509 -in ${SERVICE_DIR}/server.pem -fingerprint -sha256 -noout \\"
echo "      | cut -d= -f2 | tr -d ':' | tr '[:upper:]' '[:lower:]'"
echo ""
echo "  Copy that hex value into the 'fingureprint' field in:"
echo "    • /opt/agni-router/agni-config.yaml  (Router.Seeder.fingureprint)"
echo "    • /opt/agni-nova/agni-config.yaml    (Nova.Seeder.fingureprint)"
echo "    • Agent's agni-config.yaml           (Agent.Seeder.fingureprint)"
echo ""
echo "  Useful commands:"
echo "    View logs  : tail -f ${LOG_FILE}"
echo "    Stop       : kill \$(cat ${PID_FILE})"
echo "    Status     : kill -0 \$(cat ${PID_FILE}) && echo running || echo stopped"
echo ""
