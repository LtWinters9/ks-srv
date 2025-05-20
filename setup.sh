#!/bin/bash
set -e

# Ensure we are running the script as root
if [[ $EUID -ne 0 ]]; then
  echo "Aborting: must be run as root."
  exit 1
fi

# Prompt for confirmation
while true; do
  read -rp "Do you want to proceed? (yes/no): " yn
  case "$yn" in
    [Yy][Ee][Ss] ) echo "OK, proceeding..."; break;;
    [Nn][Oo] ) echo "Aborted."; exit 1;;
    * ) echo "Invalid response. Please type 'yes' or 'no'.";;
  esac
done

# Display script information
cat <<EOF
-----------------------------------------------------------------
This script sets the hostname and performs a full update.
Contact: [your@email.email]
-----------------------------------------------------------------
EOF

# Function to set the hostname
set_hostname() {
  echo "Enter the full hostname (e.g., edge.example.net):"
  read -rp "Hostname: " NHST
  if [[ -z "$NHST" ]]; then
    echo "Hostname cannot be empty."
    exit 1
  fi
  hostnamectl set-hostname "$NHST"
  hostnamectl set-hostname "$NHST" --pretty
  echo "Hostname set to: $NHST"
  sleep 1
  clear
  echo "Updating $NHST..."
}

# Function to perform system update
start_update() {
  echo "Starting system update..."
  apt-get -qq update && apt-get upgrade -y 2>/dev/null
  sleep 1
  apt-get -qq --with-new-pkgs upgrade -y 2>/dev/null
}

# Function to clean up after update
cleanup() {
  apt-get -qq autoremove -y 2>/dev/null
}

# Function to send alert email
send_alert() {
  SMTP_TO="${SMTP_TO:-admin@example.com}"
  SMTP_FROM="${SMTP_FROM:-noreply@example.com}"
  SMTP_SERVER="${SMTP_SERVER:-smtp.example.com}"
  SMTP_USER="${SMTP_USER:-user@example.com}"
  SMTP_AUTH="${SMTP_AUTH:-$(< /root/.smtp_password)}"
  SUBJECT="UPDATE FAILED for ${HOSTNAME}"
  BODY="System update failed on $(date '+%Y-%m-%d %H:%M:%S') for host: ${HOSTNAME}"
  swaks --to "$SMTP_TO" --from "$SMTP_FROM" --server "$SMTP_SERVER" \
        --auth-user "$SMTP_USER" --auth-password "$SMTP_AUTH" \
        --body "$BODY" --header "Subject: $SUBJECT"
}

# Main script execution
if set_hostname; then
  if start_update; then
    cleanup
    echo "${HOSTNAME}: Update complete!"
    exit 0
  else
    echo "${HOSTNAME}: Update failed!"
    echo "Sending notification..."
    send_alert
  fi
else
  echo "Setup failed - sending alert..."
  send_alert
fi
