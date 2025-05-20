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

## License
MIT License
----------------------------------------------------------------------
