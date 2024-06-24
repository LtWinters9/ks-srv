#!/bin/bash

set -e

# -------------------------------------------
# Ensure we are running the updater  as root
# -------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "  Aborting because you are not root" ; exit 1
fi

cat <<EOF
  -----------------------------------------------------------------
  This script sets the srv_hostname and updates it fully.
  -----------------------------------------------------------------
EOF

# -------------------------------------------
# Functions
# -------------------------------------------

function start_script {
sudo apt-get -qq install -y swaks 2> /dev/null
echo "Please type your full hostname"
echo "Example: edge.kloudstack.net"
echo ""
read NHST
# Set names
sudo hostnamectl set-hostname ${NHST}
sudo hostnamectl set-hostname ${NHST} --pretty
echo "Your hostname is now ${NHST}"
sleep 1
clear
echo "Updating ${NHST}"
}

function end_script {
./update-minor.sh
}

###### Script start
./toast.sh
echo ""
if start_script
then
 end_script
 exit 0
else
 echo " Setup failed - sending email"
./alert.sh
fi
