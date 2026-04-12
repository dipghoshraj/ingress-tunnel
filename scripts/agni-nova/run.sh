#!/bin/bash
# =============================================================================
# Agni Nova — Run Script
# Starts agni-nova as a background (nohup) process.
# Must be run as root (or with sudo).
# The service always executes inside SERVICE_DIR so that agni-config.yaml is
# found correctly (it is read from the current working directory at startup).
# =============================================================================
set -euo pipefail

# ── Constants ─────────────────────────────────────────────────────────────────
BINARY_NAME="agni-nova"
INSTALL_PATH="/usr/local/bin/${BINARY_NAME}"
SERVICE_DIR="/opt/agni-nova"
LOG_FILE="${SERVICE_DIR}/agni-nova.log"
PID_FILE="${SERVICE_DIR}/agni-nova.pid"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[agni-nova]${NC} $*"; }
warn()  { echo -e "${YELLOW}[agni-nova]${NC} $*"; }
error() { echo -e "${RED}[agni-nova] ERROR:${NC} $*" >&2; }

# ── Pre-flight checks ─────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  error "This script must be run as root or with sudo."
  exit 1
fi

if [[ ! -x "${INSTALL_PATH}" ]]; then
  error "Binary not found at ${INSTALL_PATH}. Run setup.sh first."
  exit 1
fi

if [[ ! -f "${SERVICE_DIR}/agni-config.yaml" ]]; then
  error "Config not found at ${SERVICE_DIR}/agni-config.yaml. Run setup.sh first."
  exit 1
fi

# ── Already running? ──────────────────────────────────────────────────────────
if [[ -f "${PID_FILE}" ]]; then
  OLD_PID=$(cat "${PID_FILE}")
  if kill -0 "${OLD_PID}" 2>/dev/null; then
    warn "agni-nova is already running (PID ${OLD_PID})."
    warn "Stop it first:  kill ${OLD_PID}"
    exit 1
  else
    warn "Stale PID file found (PID ${OLD_PID} is not running). Removing."
    rm -f "${PID_FILE}"
  fi
fi

# ── Start service ─────────────────────────────────────────────────────────────
info "Starting agni-nova…"
info "  Working dir : ${SERVICE_DIR}"
info "  Log file    : ${LOG_FILE}"
info "  PID file    : ${PID_FILE}"

cd "${SERVICE_DIR}"
nohup "${INSTALL_PATH}" >> "${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"

sleep 1   # brief pause so any immediate crash shows in the log

if kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  info "agni-nova started successfully (PID $(cat "${PID_FILE}"))."
else
  error "agni-nova exited immediately. Check the log for details:"
  error "  tail -n 40 ${LOG_FILE}"
  rm -f "${PID_FILE}"
  exit 1
fi

echo ""
echo "  Useful commands:"
echo "    View logs  : tail -f ${LOG_FILE}"
echo "    Stop       : kill \$(cat ${PID_FILE})"
echo "    Status     : kill -0 \$(cat ${PID_FILE}) && echo running || echo stopped"
echo ""
