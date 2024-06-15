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
  This script updates the server
  -----------------------------------------------------------------
EOF

# -------------------------------------------
# Vars
# -------------------------------------------
SMTP_TO=""
SMTP_FROM=""
SMTP_SERVER=""
SMTP_USER=""
SMTP_AUTH=''

HN=${HOSTNAME}

########################
# functions start here #
########################

function start_script {
echo "Starting Script"
sudo apt-get update && sudo apt-get upgrade -y 2> /dev/null
clear
sleep 1
sudo apt-get --with-new-pkgs upgrade -y 2> /dev/null
}

function end_script {
clear
echo "Cleaning up"
sudo apt-get autoremove -y 2> /dev/null
clear
}

if start_script
then
 end_script
echo Finished updating - ${HN}
 exit 0
else
 echo " Script failed - sending email"
 swaks --to ${SMTP_TO} --from ${SMTP_FROM} --server ${SMTP_SERVER} --auth-user ${SMTP_USER} --auth-password ${SMTP_AUTH} --body "failed to update on $(date '+%Y-%m-%d')" --header 'Subject: UPDATE FAILED for ${HN}' ; exit 1
fi
