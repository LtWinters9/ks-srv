# srv — Server Management Scripts

A collection of scripts for initial server setup, ongoing maintenance (Debian/Ubuntu).

---

## Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` | First-boot: set hostname and run a full system update |
| `update.sh` | Ongoing: run system upgrades with selectable mode |

---

## Prerequisites

- Debian/Ubuntu server
- Run as **root**
- [`swaks`](https://github.com/jetmore/swaks) installed for email alerts (`apt install swaks`)
- `.env` file configured (see below)

---

## Configuration

All scripts share a single `.env` file in this directory:

```bash
cp .env.example .env
nano .env
```

| Variable | Description |
|----------|-------------|
| `SMTP_TO` | Alert recipient address |
| `SMTP_FROM` | Sender address |
| `SMTP_SERVER` | SMTP relay hostname |
| `SMTP_USER` | SMTP authentication user |
| `SMTP_PASSWORD` | SMTP authentication password |

> If `SMTP_PASSWORD` is not set, email alerts are skipped silently — scripts still run normally.

---

## Usage

### Initial Server Setup

Run once on a fresh server to set the hostname and update all packages:

```bash
chmod +x setup.sh
sudo ./setup.sh
```

- Prompts for confirmation before making changes
- Prompts for the full hostname (e.g. `edge.kloudstack.net`)
- Runs `apt update`, `apt upgrade`, and `apt autoremove`
- Logs to `/var/log/srv_setup.log`
- Sends an email alert via `swaks` if the script fails

---

### System Update

Run on existing servers to upgrade packages:

```bash
chmod +x update.sh
sudo ./update.sh
```

Select upgrade type when prompted:

| Option | Mode | Description |
|--------|------|-------------|
| `1` | Standard | Safe upgrades only (default) |
| `2` | Full | Includes dependency changes |
| `3` | Dry-run | Simulate without applying |

- Logs to `/var/log/upgrade_script.log`
- Sends an email alert via `swaks` if the update fails
- Defaults to **Standard** in non-interactive (cron) mode

---

## Logs

| Script | Log file |
|--------|----------|
| `setup.sh` | `/var/log/srv_setup.log` |
| `update.sh` | `/var/log/upgrade_script.log` |
