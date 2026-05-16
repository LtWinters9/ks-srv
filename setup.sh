#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Server Setup — sets hostname and performs an initial full system update.
# ─────────────────────────────────────────────────────────────────────────────

LOG_FILE="/var/log/srv_setup.log"

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
    local subject="SETUP FAILED: ${HOSTNAME}"
    local body="Server setup failed on $(date '+%Y-%m-%d %H:%M:%S') for host: ${HOSTNAME}. Check ${LOG_FILE} for details."

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
    log "Setup failed — sending alert..."
    send_alert
}

# ─────────────────────────────────────────────────────────────────────────────

check_root() {
    [[ $EUID -eq 0 ]] || die "Must be run as root."
}

confirm() {
    while true; do
        read -rp "Do you want to proceed? (yes/no): " yn
        case "$yn" in
            [Yy][Ee][Ss]) return 0 ;;
            [Nn][Oo])     echo "Aborted."; exit 0 ;;
            *)            echo "Please type 'yes' or 'no'." ;;
        esac
    done
}

set_hostname() {
    read -rp "Enter the full hostname (e.g., edge.kloudstack.net): " NHST
    [[ -n "$NHST" ]] || die "Hostname cannot be empty."

    hostnamectl set-hostname "$NHST"
    hostnamectl set-hostname "$NHST" --pretty
    log "Hostname set to: $NHST"
}

run_update() {
    log "Updating package lists..."
    apt-get -qq update >> "$LOG_FILE" 2>&1

    log "Running upgrade..."
    DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y >> "$LOG_FILE" 2>&1

    log "Running upgrade (with new packages)..."
    DEBIAN_FRONTEND=noninteractive apt-get -qq --with-new-pkgs upgrade -y >> "$LOG_FILE" 2>&1

    log "Cleaning up..."
    apt-get -qq autoremove -y >> "$LOG_FILE" 2>&1
}

# ─────────────────────────────────────────────────────────────────────────────

main() {
    check_root

    cat <<EOF
─────────────────────────────────────────────────────────────────
 Server Setup — sets hostname and performs a full system update.
─────────────────────────────────────────────────────────────────
EOF

    confirm
    trap on_error ERR

    set_hostname
    run_update

    log "Setup complete for ${HOSTNAME}."
}

main
