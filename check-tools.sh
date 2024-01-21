#!/usr/bin/env bash

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
COL_NC='\033[0m'
COL_LIGHT_YELLOW='\033[1;33m'
INFO="[${COL_LIGHT_YELLOW}~${COL_NC}]"
OVER="\\r\\033[K"

if [[ "${AWVS_DEBUG}" == "true" ]]; then
    set -ex
fi

msg_info() {
    printf "${INFO}  %s ${COL_LIGHT_YELLOW}...${COL_NC}" "${1}" 1>&2
    sleep 3
}

msg_ok() {
    printf "${OVER}  [\033[1;32m✓${COL_NC}]  %s\n" "${1}" 1>&2
}

msg_err() {
    printf "${OVER}  [\033[1;31m✗${COL_NC}]  %s\n" "${1}" 1>&2
    exit 1
}

msg_over() {
    printf "${OVER}%s" "  " 1>&2
}

typeApp() {
    if ! type "$1" >/dev/null 2>&1; then
        apt-get -qq update
        apt-get -qq install "$1"
    fi
}

typeApp unzip
typeApp curl

LAST_VERSION="$(cat /awvs/LAST_VERSION | sed 's/ //g' 2>/dev/null)"

if [[ "$LAST_VERSION" == 14.* ]]; then
    check_zip_url="https://raw.githubusercontent.com/k4t3pr0/acunetix-latest/main/awvs14_listen.zip"
fi

if [[ "$LAST_VERSION" == 15.* ]]; then
    check_zip_url="https://raw.githubusercontent.com/k4t3pr0/acunetix-latest/main/awvs15_listen.zip"
fi

if [[ -z "$check_zip_url" ]]; then
    check_zip_url="https://raw.githubusercontent.com/k4t3pr0/acunetix-latest/main/awvs_listen.zip"
fi

if [[ "$(curl -sLko /awvs/awvs_listen.zip ${check_zip_url} -w "%{http_code}")" != 200 ]]; then
    msg_err "Download awvs_listen.zip failed"
else
    msg_ok "Download awvs_listen.zip Success! "
fi

if ! unzip -o /awvs/awvs_listen.zip -d /tmp/ >/dev/null 2>&1; then
    msg_err "Unzip awvs_listen.zip failed"
else
    msg_ok "Unzip awvs_listen.zip Success! "
fi

if ls /tmp/{license_info.json,wa_data.dat,wvsc} 1>/dev/null 2>&1; then
    msg_ok "All files exist"
else
    msg_err "At least one file does not exist"
fi

chmod 444 /tmp/{license_info.json,wa_data.dat}
if [ $? -eq 0 ]; then
    msg_ok "Chmod {license_info.json,wa_data.dat} Success! "
else
    msg_err "Chmod {license_info.json,wa_data.dat} failed"
fi

chmod 777 /tmp/wvsc
if [ $? -eq 0 ]; then
    msg_ok "Chmod wvsc Success! "
else
    msg_err "Chmod wvsc failed"
fi

chown acunetix:acunetix /tmp/{license_info.json,wa_data.dat}
if [ $? -eq 0 ]; then
    msg_ok "Chown {license_info.json,wa_data.dat} Success! "
else
    msg_err "Chown {license_info.json,wa_data.dat} failed"
fi

chattr -i /home/acunetix/.acunetix/data/license/* > /dev/null 2>&1
rm -rf /home/acunetix/.acunetix/data/license/*

if [ $? -eq 0 ]; then
    msg_ok "rm license/* Success! "
else
    msg_err "chattr license/* failed"
fi

if ! mv /tmp/{license_info.json,wa_data.dat} /home/acunetix/.acunetix/data/license/ >/dev/null 2>&1; then
    msg_err "Move {license_info.json,wa_data.dat} failed"
else
    msg_ok "Move {license_info.json,wa_data.dat} Success! "
fi

if ! mv /tmp/wvsc /home/acunetix/.acunetix/v_*/scanner/ >/dev/null 2>&1; then
    msg_err "Move wvsc failed"
else
    msg_ok "Move wvsc Success! "
fi

chattr +i /home/acunetix/.acunetix/data/license/{license_info.json,wa_data.dat}
if [ $? -eq 0 ]; then
    msg_ok "chattr +i {license_info.json,wa_data.dat} Success! "
else
    printf "${OVER}  [\033[1;31m✗${COL_NC}]  %s\n" "chattr +i {license_info.json,wa_data.dat} failed" 1>&2
fi

for host in bxss.me erp.acunetix.com services.invicti.com api.segment.io cdn.segment.io data.pendo.io cdn.pendo.io bxss.s3.dualstack.us-west-2.amazonaws.com s3-r-w.dualstack.us-west-2.amazonaws.com; do grep -q $host /etc/hosts || {
        echo "0.0.0.0 $host" >> /awvs/.hosts
        echo ":: $host" >> /awvs/.hosts
}; done
if [ $? -eq 0 ]; then
    msg_ok "Add HOSTS Success! "
else
    msg_err "Add HOSTS failed"
fi

if ! rm -rf /awvs/awvs_listen.zip >/dev/null 2>&1; then
    msg_err "Clean failed"
else
    msg_ok "Clean Success! "
fi
