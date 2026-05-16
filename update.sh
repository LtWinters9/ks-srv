#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Server Update — runs a system upgrade with optional mode selection.
# ─────────────────────────────────────────────────────────────────────────────

LOG_FILE="/var/log/upgrade_script.log"

ENV_FILE="$(dirname "$0")/.env"
[[ -f "$ENV_FILE" ]] || { echo "Missing .env file: $ENV_FILE"; exit 1; }
# shellcheck source=.env
source "$ENV_FILE"

# ─────────────────────────────────────────────────────────────────────────────

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

die() {
    log "ERROR: $*"
    exit 1
}

send_alert() {
    local subject="UPDATE FAILED: ${HOSTNAME}"
    local body="System update failed on $(date '+%Y-%m-%d %H:%M:%S') for host: ${HOSTNAME}. Check ${LOG_FILE} for details."

    if [[ -z "${SMTP_PASSWORD:-}" ]]; then
        log "Warning: SMTP_PASSWORD not set in .env — skipping alert."
        return
    fi

    swaks \
        --to "$SMTP_TO" \
        --from "$SMTP_FROM" \
        --server "$SMTP_SERVER" \
        --auth-user "$SMTP_USER" \
        --auth-password "$SMTP_PASSWORD" \
        --header "Subject: $subject" \
        --body "$body" \
        >> "$LOG_FILE" 2>&1 || log "Warning: failed to send alert email."
}

on_error() {
    log "Update failed — sending alert..."
    send_alert
}

on_exit() {
    log "Script exited."
}

# ─────────────────────────────────────────────────────────────────────────────

check_root() {
    [[ $EUID -eq 0 ]] || die "Must be run as root."
}

select_upgrade_type() {
    if [[ ! -t 0 ]]; then
        log "Non-interactive shell detected — defaulting to standard upgrade."
        upgrade_type="standard"
        return
    fi

    echo ""
    echo "Select upgrade type:"
    echo "  1) Standard     — safe upgrades only"
    echo "  2) Full         — includes dependency changes"
    echo "  3) Dry-run      — simulate without applying"
    echo ""
    read -rp "Enter choice [1-3] (default: 1): " choice

    case "${choice:-1}" in
        1|"") upgrade_type="standard" ;;
        2)    upgrade_type="full" ;;
        3)    upgrade_type="dry" ;;
        *)    die "Invalid selection: $choice" ;;
    esac
}

run_upgrade() {
    log "Updating package lists..."
    apt-get -qq update >> "$LOG_FILE" 2>&1

    case "$1" in
        standard)
            log "Running standard upgrade..."
            DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y >> "$LOG_FILE" 2>&1
            ;;
        full)
            log "Running full upgrade..."
            DEBIAN_FRONTEND=noninteractive apt-get -qq full-upgrade -y >> "$LOG_FILE" 2>&1
            ;;
        dry)
            log "Running dry-run upgrade..."
            apt-get -qq upgrade --dry-run >> "$LOG_FILE" 2>&1
            ;;
    esac

    if [[ "$1" != "dry" ]]; then
        log "Cleaning up..."
        apt-get -qq autoremove -y >> "$LOG_FILE" 2>&1
    fi

    log "Upgrade complete (mode: $1)."
}

# ─────────────────────────────────────────────────────────────────────────────

main() {
    check_root
    trap on_error ERR
    trap on_exit EXIT

    log "─── Update started on ${HOSTNAME} ───"
    select_upgrade_type
    run_upgrade "$upgrade_type"
}

main
