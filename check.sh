#!/usr/bin/env bash

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
COL_NC='\033[0m'
COL_LIGHT_YELLOW='\033[1;33m'
INFO="[${COL_LIGHT_YELLOW}~${COL_NC}]"
OVER="\\r\\033[K"
DockerImage=$1
DOCKER_INSTALL_URL="https://raw.githubusercontent.com/k4t3pr0/acunetix-latest/main/docker_init.sh"
TOOLS_URL="https://raw.githubusercontent.com/k4t3pr0/acunetix-latest/main/check-tools.sh"

msg_info() {
  printf "${INFO}  %s ${COL_LIGHT_YELLOW}...${COL_NC}" "${1}" 1>&2
  sleep 3
}

msg_ok() {
  printf "${OVER}  [\033[1;32m✓${COL_NC}]  %s\n" "${1}" 1>&2
  msg_over
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
    msg_err "Please install $1"
  fi
}

msg_logo() {
  clear
  echo -e "\n  \033[1;31mCreated by k4t3pr0\033[0m"
  echo -e "  \033[1;32mhttps://github.com/k4t3pr0\033[0m"
}

getDocker() {
  if [[ "$(curl -sLko /dev/null ${DOCKER_INSTALL_URL} -w "%{http_code}")" != 200 ]]; then
    msg_err "Docker install script not found"
  fi
  curl -sLk "${DOCKER_INSTALL_URL}" | bash
}

clean() {
  msg_info "Clear historical Acunetix images"
  if [ -z "$(docker images -aqf reference="${DockerImage}")" ]; then
    if ! docker rmi -f "$(docker images -aqf reference="${DockerImage}" >/dev/null 2>&1)"; then
      msg_err "Failed to clear historical Acunetix images"
    fi
  fi
  printf "${OVER}  [\033[1;32m✓${COL_NC}]  %s\n\n" "Clear historical Acunetix images Success!" 1>&2
}

check() {
  msg_info "Starting cracking Acunetix..."
  msg_over
  if [[ "$(curl -sLko /dev/null ${TOOLS_URL} -w "%{http_code}")" != 200 ]]; then
    msg_err "Get check-tools.sh failed"
  fi
  docker exec acunetix bash -c "AWVS_DEBUG=${AWVS_DEBUG} bash <(curl -sLk ${TOOLS_URL})"
  msg_over
  if ! docker restart acunetix >/dev/null 2>&1; then
    msg_err "Restart Acunetix failed"
  fi
  msg_ok "Crack Over!"
}

logs() {
  docker logs acunetix 2>&1 | head -n 24
  echo
  msg_over
}

msg_logo
msg_ok "Start Install "
msg_info "Will Del Container Like Acunetix, Sleep 5S!"
sleep 2
msg_over

if [ "${AWVS_DEBUG}" = "true" ]; then
   msg_ok "Debug Mode "
   TOOLS_URL="http://192.168.0.235/check-tools.sh"
fi

typeApp curl
if ! type docker >/dev/null 2>&1; then
  echo -ne "${OVER}  "
  msg_info "Docker Is Not Installed, Is Installing!"
  msg_over
  getDocker
fi

if ! docker ps >/dev/null 2>&1; then
  echo -ne "${OVER}  "
  msg_err "Docker Not Running, Please Start Docker!"
fi

if [ -n "$(docker ps -aq --filter name=acunetix 2>/dev/null)" ]; then
  if ! docker rm -f "$(docker ps -aq --filter name=acunetix)" >/dev/null 2>&1; then
    msg_err "Delete Acunetix container failed"
  fi
  msg_ok "The Container Acunetix Was Deleted Success!"
fi

port="3443"
if [ -n "$(docker ps -aq --filter publish=3443 2>/dev/null)" ]; then
  port="3445"
  msg_info "Acunetix Port 3443 Is Occupied, Will Use Port 3445"
  msg_over
fi

if ! docker run -itd --name acunetix --cap-add LINUX_IMMUTABLE -p "${port}:3443" --restart=always "${DockerImage}" >/dev/null 2>&1; then
  msg_err "Create Acunetix container failed"
fi
msg_ok "Create Acunetix container Success!"

check
logs
clean
