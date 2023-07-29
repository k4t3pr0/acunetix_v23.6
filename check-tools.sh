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

if [[ ! -d /tmp/awvs ]]; then
  msg_err "Awvs dict not found"
  exit 1
fi

if [[ -f /tmp/awvs/license_info.json ]]; then
  if ! chmod 444 /tmp/awvs/license_info.json >/dev/null 2>&1; then
    msg_err "Chmod license_info.json failed"
  else
    msg_ok "Chmod license_info.json Success! "
  fi
fi

if [[ -f /tmp/awvs/wa_data.dat ]]; then
  if ! chmod 444 /tmp/awvs/wa_data.dat >/dev/null 2>&1; then
    msg_err "Chmod wa_data.dat failed"
  else
    msg_ok "Chmod wa_data.dat Success! "
  fi
fi

if [[ -f /tmp/awvs/wvsc ]]; then
  if ! chmod 777 /tmp/awvs/wvsc >/dev/null 2>&1; then
    msg_err "Chmod wvsc failed"
  else
    msg_ok "Chmod wvsc Success! "
  fi
fi

if [[ -f /tmp/awvs/wa_data.dat ]]; then
  if ! chown acunetix:acunetix /tmp/awvs/wa_data.dat >/dev/null 2>&1; then
    msg_err "Chown wa_data.dat failed"
  else
    msg_ok "Chown wa_data.dat Success! "
  fi
fi

if [[ -f /tmp/awvs/license_info.json ]]; then
  if ! mv /tmp/awvs/license_info.json /home/acunetix/.acunetix/data/license/ >/dev/null 2>&1; then
    msg_err "Move license_info.json failed"
  else
    msg_ok "Move license_info.json Success! "
  fi
fi

if [[ -f /tmp/awvs/wa_data.dat ]]; then
  if ! mv /tmp/awvs/wa_data.dat /home/acunetix/.acunetix/data/license/ >/dev/null 2>&1; then
    msg_err "Move wa_data.dat failed"
  else
    msg_ok "Move wa_data.dat Success! "
  fi
fi

if [[ -f /tmp/awvs/wvsc ]]; then
  if ! mv /tmp/awvs/wvsc /home/acunetix/.acunetix/v_*/scanner/ >/dev/null 2>&1; then
    msg_err "Move wvsc failed"
  else
    msg_ok "Move wvsc Success! "
  fi
fi


if ! (echo '127.0.0.1 updates.acunetix.com' >/awvs/.hosts) >/dev/null 2>&1; then
  msg_err "Add HOSTS.1 failed"
else
  msg_ok "Add HOSTS.1 Success! "
fi

if ! (echo '127.0.0.1 erp.acunetix.com' >>/awvs/.hosts) >/dev/null 2>&1; then
  msg_err "Add HOSTS.2 failed"
else
  msg_ok "Add HOSTS.2 Success! "
fi

if ! (echo '127.0.0.1 telemetry.invicti.com' >>/awvs/.hosts) >/dev/null 2>&1; then
  msg_err "Add HOSTS.3 failed"
else
  msg_ok "Add HOSTS.3 Success! "
fi



if ! rm -rf /tmp/awvs >/dev/null 2>&1; then
  msg_err "Clean failed"
else
  msg_ok "Clean Success! "
fi
