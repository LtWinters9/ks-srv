#!/bin/bash

LOG_FILE="/var/log/upgrade_script.log"
trap 'on_exit' EXIT

# Ensure only root can run the script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   exit 1
fi

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Cleanup function
on_exit() {
    log "Script exited."
    clear
}

# Update package list
update_system() {
    log "Updating package list..."
    if ! apt update -y >> "$LOG_FILE" 2>&1; then
        log "Failed to update package list."
        exit 1
    fi
}

# Perform upgrade based on user choice
perform_upgrade() {
    case $1 in
        standard)
            log "Performing standard upgrade..."
            apt upgrade -y >> "$LOG_FILE" 2>&1
            ;;
        dry)
            log "Performing dry-run upgrade..."
            apt upgrade --dry-run >> "$LOG_FILE" 2>&1
            ;;
        full)
            log "Performing full upgrade..."
            apt full-upgrade -y >> "$LOG_FILE" 2>&1
            ;;
        *)
            log "Invalid upgrade type: $1"
            exit 1
            ;;
    esac

    if [[ $? -ne 0 ]]; then
        log "Upgrade failed."
        exit 1
    else
        log "Upgrade completed successfully."
    fi
}

# Prompt user for upgrade type unless running non-interactively (e.g., via cron)
select_upgrade_type() {
    if [[ ! -t 0 ]]; then
        # Non-interactive shell (likely cron)
        log "Non-interactive shell detected. Defaulting to standard upgrade."
        upgrade_type="standard"
    else
        echo "Select upgrade type:"
        echo "1) Standard"
        echo "2) Dry-run"
        echo "3) Full"
        read -rp "Enter choice [1-3]: " choice

        case $choice in
            1) upgrade_type="standard" ;;
            2) upgrade_type="dry" ;;
            3) upgrade_type="full" ;;
            *) log "Invalid selection."; exit 1 ;;
        esac
    fi
}

# Main execution flow
main() {
    log "Script started."
    update_system
    select_upgrade_type
    perform_upgrade "$upgrade_type"
}

main
