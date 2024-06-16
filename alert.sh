#!/bin/bash

set -e

SMTP_TO=""
SMTP_FROM=""
SMTP_SERVER=""
SMTP_USER=""
SMTP_AUTH=''

swaks --to ${SMTP_TO} --from ${SMTP_FROM} --server ${SMTP_SERVER} --auth-user ${SMTP_USER} --auth-password ${SMTP_AUTH} --body "failed to update on $(date '+%Y-%m-%d')" --header 'Subject: UPDATE FAILED for servername' ; exit 1
