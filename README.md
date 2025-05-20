# 🛠️ System Update & Hostname Configuration Script

## Description
This script automates the process of setting a hostname, updating the system, cleaning up unused packages, and sending an alert email if the update fails.

## Features
- Root privilege check
- User confirmation prompt
- Hostname configuration
- Silent system update
- Cleanup of unused packages
- Email alert on failure

## Requirements
- Debian-based Linux system
- `swaks` installed
- SMTP credentials stored in `/root/.smtp_password`

## Usage
\`\`\`bash
sudo ./setup.sh
\`\`\`

## SMTP Setup
Ensure the following environment variables are set or modify the script:
- SMTP_TO
- SMTP_FROM
- SMTP_SERVER
- SMTP_USER
- SMTP_AUTH (or stored in `/root/.smtp_password`)

----------------------------------------------------------------------
# 🛠️ System Upgrade Script (`update.sh`)

This Bash script automates the process of updating and upgrading a Debian-based Linux system. It supports interactive and non-interactive modes, logs all actions, and provides multiple upgrade options.

## 🔍 Features

- **Root check**: Ensures the script is run with root privileges.
- **Logging**: All actions are logged to `/var/log/upgrade_script.log`.
- **Upgrade options**:
  - `Standard`: Regular `apt upgrade`.
  - `Dry-run`: Simulates the upgrade without making changes.
  - `Full`: Executes `apt full-upgrade`.
- **Interactive prompt**: Asks the user to choose an upgrade type unless run non-interactively (e.g., via cron).
- **Clean exit**: Logs script termination and clears the terminal.

## 🚀 Usage

```bash
sudo ./update.sh
