#!/usr/bin/env bash

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
COL_NC='\033[0m'
COL_LIGHT_YELLOW='\033[1;33m'
INFO="[${COL_LIGHT_YELLOW}~${COL_NC}]"
OVER="\\r\\033[K"
DockerImage=$1
TOOLS_URL="https://raw.githubusercontent.com/k4t3pr0/acunetix_v23.6/main/check-tools.sh"
if [ "${AWVS_DEBUG}" = "true" ]; then
fi

if [[ $(curl -s -I www.google.com >/dev/null) -eq 0 ]]; then
  ghproxy="https:/"
else
  ghproxy="https://ghproxy.com/https:/"
fi
DOCKER_INSTALL_URL="${ghproxy}/https://raw.githubusercontent.com/k4t3pr0/acunetix_v23.6/main/docker_init.sh"

# set msg
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

# Logo
msg_logo() {
  clear
  echo -e "\n  \033[1;31m __        _____     __    ________                     _______ \033[0m"  
  echo -e "  \033[1;32m|  | __   /  |  |  _/  |_  \_____  \  ______   _______  \   _  \ \033[0m" 
  echo -e "  \033[1;33m|  |/ /  /   |  |_ \   __\   _(__  <  \____ \  \_  __ \ /  /_\  \ \033[0m"
  echo -e "  \033[1;34m|    <  /    ^   /  |  |    /       \ |  |_> >  |  | \/ \  \_/   \\033[0m"
  echo -e "  \033[1;35m|__|_ \ \____   |   |__|   /______  / |   __/   |__|     \_____  /\033[0m"
  echo -e "  \033[1;36m     \/      |__|                 \/  |__|                     \/ \033[0m"
  echo -e "\n  \033[1;36mhttps://github.com/k4t3pr0 \033[0m"
}


# install Docker
getDocker() {
  if [[ "$(curl -sLko /dev/null ${DOCKER_INSTALL_URL} -w "%{http_code}")" != 200 ]]; then
    msg_err "Docker install script not found"
  fi
  curl -sLk "${DOCKER_INSTALL_URL}" | bash
}

clean() {
  msg_info "Clear historical images"
  if [ -z "$(docker images -aqf reference="${DockerImage}")" ]; then
    if ! docker rmi -f "$(docker images -aqf reference="${DockerImage}" >/dev/null 2>&1)"; then
      msg_err "Failed to clear historical Acunetix images"
    fi
  fi
  printf "${OVER}  [\033[1;32m✓${COL_NC}]  %s\n\n" "Clear historical Acunetix images Success!" 1>&2
}

check() {
  msg_info "Starting cracking ahihi..."
  msg_over
  LAST_VERSION="$(docker exec acunetix bash -c "cat /awvs/LAST_VERSION | sed 's/ //g' 2>/dev/null")"
  if [[ $(curl -s -I www.google.com >/dev/null) -eq 0 ]]; then
    tmpLAST_VERSION="$(curl -sLk ${ghproxy}/raw.githubusercontent.com/k4t3pr0/acunetix_v23.6/main/LAST_VERSION)"
  else
    tmpLAST_VERSION="$(curl -sLk ${ghproxy}/ghproxy.com/https://raw.githubusercontent.com/k4t3pr0/acunetix_v23.6/main/LAST_VERSION)"
  fi

  if [[ "${LAST_VERSION}" != "${tmpLAST_VERSION}" ]]; then
    printf "${OVER}  [\033[1;31m✗${COL_NC}]  %s\n" "${LAST_VERSION} != ${tmpLAST_VERSION} (latest version), please update the image" 1>&2
    msg_over
  else
    msg_ok "The current version is the latest version"
    msg_over
  fi

  if [[ "$LAST_VERSION" == 14.* ]]; then
    check_zip_url="https://github.com/k4t3pr0/acunetix_v23.6/raw/main/awvs14_listen.zip"
  fi

  if [[ "$LAST_VERSION" == 15.* ]]; then
    check_zip_url="https://github.com/k4t3pr0/acunetix_v23.6/raw/main/awvs15_listen.zip"
  fi

  if [[ -z "$check_zip_url" ]]; then
    check_zip_url="https://github.com/k4t3pr0/acunetix_v23.6/raw/main/awvs_listen.zip"
  fi

  if [[ "$(curl -sLko /tmp/awvs_listen.zip ${check_zip_url} -w "%{http_code}")" != 200 ]]; then
    msg_err "Download awvs_listen.zip failed"
  else
    msg_ok "Download awvs_listen.zip Success! "
  fi

  mkdir /tmp/awvs >/dev/null 2>&1

  if ! unzip -o /tmp/awvs_listen.zip -d /tmp/awvs/ >/dev/null 2>&1; then
    msg_err "Unzip awvs_listen.zip failed"
  else
    msg_ok "Unzip awvs_listen.zip Success! "
  fi

  docker cp /tmp/awvs acunetix:/tmp/awvs 2>/dev/null

  if [[ "$(curl -sLko /dev/null ${TOOLS_URL} -w "%{http_code}")" != 200 ]]; then
    msg_err "Get check-tools.sh failed"
  fi
  docker exec acunetix bash -c "AWVS_DEBUG=${AWVS_DEBUG} bash <(curl -sLk ${TOOLS_URL})"
  msg_over
 
  printf "\033[1A"
  printf "\033[K"
  if ! rm -rf /tmp/awvs >/dev/null 2>&1; then
    msg_err "Clean failed"
  else
    msg_ok "Clean Success! "
  fi
  
  if ! docker restart acunetix >/dev/null 2>&1; then
    msg_err "Restart Acunetix failed"
  fi
  msg_ok "Crack Over!"
}

# 打印日志
logs() {
  docker logs acunetix 2>&1 | head -n 24
  echo
  msg_over
}

# 主程序
msg_logo # 打印logo
msg_ok "Start Install "
msg_info "Will Del Container Like Acunetix, Sleep 5S!"
sleep 2
msg_over

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

msg_info "Docker Pull ${DockerImage}"
msg_over
while read -r line; do
  msg_over
  printf "${INFO}  %s ${COL_LIGHT_YELLOW}...${COL_NC}" "${line}" 1>&2
done < <(docker pull "${DockerImage}" || (msg_err "Docker Error"))
msg_over
msg_ok "Docker Pull ${DockerImage} Success!"

if ! docker run -itd --name acunetix -p "${port}:3443" --restart=always "${DockerImage}" >/dev/null 2>&1; then
  msg_err "Create Acunetix container failed"
fi
msg_ok "Create Acunetix container Success!"

check
logs
clean
