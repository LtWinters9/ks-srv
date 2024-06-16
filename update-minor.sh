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
*** This script will update ${HOSTNAME} ***
-----------------------------------------------------------------
EOF

# -------------------------------------------
# Functions
# -------------------------------------------

function start_script {
echo "Starting Script"
sudo apt-get -qq update && sudo apt-get upgrade -y 2> /dev/null
sleep 1
sudo apt-get -qq --with-new-pkgs upgrade -y 2> /dev/null
}

function end_script {
sudo apt-get -qq autoremove -y 2> /dev/null
}

###### Script start
./toast.sh
echo ""
if start_script && clear
then
 end_script && clear
 echo ${HOSTNAME}: Updated!
 exit 0
else
echo ${HOSTNAME}: Failed to update!
echo "Sending Notification"
./alert.sh
fi
