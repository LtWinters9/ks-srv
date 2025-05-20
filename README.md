# 🛠️ System Maintenance Scripts

This repository contains two Bash scripts for managing Debian-based Linux systems:

- `setup.sh`: Configures hostname, updates the system, and sends failure alerts.
- `update.sh`: Automates system upgrades with logging and interactive/non-interactive modes.

---

## 📁 `setup.sh` – System Update & Hostname Configuration

### 📄 Description

This script automates:

- Hostname configuration
- System updates
- Cleanup of unused packages
- Sending an alert email if the update fails

### ✨ Features

- ✅ Root privilege check  
- ✅ User confirmation prompt  
- ✅ Silent system update  
- ✅ Cleanup of unused packages  
- ✅ Email alert on failure  

### 🧰 Requirements

- Debian-based Linux system  
- `swaks` installed  
- SMTP credentials in `/root/.smtp_password`

### 🚀 Usage

```bash
sudo chmod +x setup.sh update.sh
sudo ./setup.sh
sudo ./update.sh
