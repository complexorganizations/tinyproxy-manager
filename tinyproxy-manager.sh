#!/bin/bash

# Require script to be run as root
function super-user-check() {
  if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as super user."
    exit
  fi
}

# Check for root
super-user-check

# Detect Operating System
function dist-check() {
  if [ -e /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO=$ID
  fi
}

# Check Operating System
dist-check

# Pre-Checks system requirements
function installing-system-requirements() {
  if { [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ] || [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ] || [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ] || [ "$DISTRO" == "alpine" ] || [ "$DISTRO" == "freebsd" ]; }; then
    if { [ ! -x "$(command -v curl)" ]; }; then
      if { [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ]; }; then
        apt-get update && apt-get install curl -y
      elif { [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ]; }; then
        yum update -y && yum install curl -y
      elif { [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ]; }; then
        pacman -Syu --noconfirm curl
      elif [ "$DISTRO" == "alpine" ]; then
        apk update && apk add curl
      elif [ "$DISTRO" == "freebsd" ]; then
        pkg update && pkg install curl
      fi
    fi
  else
    echo "Error: $DISTRO not supported."
    exit
  fi
}

# Run the function and check for requirements
installing-system-requirements

# Global Var
TINYPROXY_CONFIG="/etc/tinyproxy/tinyproxy.conf"
TINYPROXY_MANGER="/etc/tinyproxy/tinyproxy-manager"
TINYPROXY_MANAGER_UPDATE="https://raw.githubusercontent.com/complexorganizations/tinyproxy-manager/main/tinyproxy-manager.sh"

if [ ! -f "$TINYPROXY_CONFIG" ]; then

  # Ask the user for their ip
  function server-input-ip() {
    echo "What IP would u like the server to take allow?"
    echo "  1) Custom (Recommended)"
    echo "  2) Ansewer #2 (Everything)"
    until [[ "$FIRST_QUESTION_SETTINGS" =~ ^[1-2]$ ]]; do
      read -rp "Subnetwork choice [1-2]: " -e -i 1 FIRST_QUESTION_SETTINGS
    done
    case $FIRST_QUESTION_SETTINGS in
    1)
      read -rp "User text: " -e -i "" FIRST_QUESTION
      ;;
    2)
      FIRST_QUESTION="0.0.0.0"
      ;;
    esac
  }

  # comments for the first question
  server-input-ip

  # comments for the first question
  function server-input-port() {
    echo "What port would u like the server to take allow?"
    echo "  1) 8080 (Recommended)"
    echo "  2) Custom (Everything)"
    until [[ "$SECOND_QUESTION_SETTINGS" =~ ^[1-2]$ ]]; do
      read -rp "Subnetwork choice [1-2]: " -e -i 1 SECOND_QUESTION_SETTINGS
    done
    case $SECOND_QUESTION_SETTINGS in
    1)
      SECOND_QUESTION="8080"
      ;;
    2)
      read -rp "User text: " -e -i "" SECOND_QUESTION
      ;;
    esac
  }

  # comments for the first question
  server-input-port

  # Pre-Checks system requirements
  function install-the-app() {
    if { [ ! -x "$(command -v tinyproxy)" ]; }; then
      if { [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ]; }; then
        apt-get update
        apt-get install tinyproxy -y
      elif { [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ]; }; then
        yum update -y
        yum install tinyproxy -y
      elif { [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ]; }; then
        pacman -Syu
        pacman -Syu --noconfirm tinyproxy
      elif [ "$DISTRO" == "alpine" ]; then
        apk update
        apk add tinyproxy
      elif [ "$DISTRO" == "freebsd" ]; then
        pkg update
        pkg install tinyproxy
      fi
    fi
  }

  # Run the function and check for requirements
  install-the-app

  function service-manager() {
    if { [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ] || [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ] || [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ] || [ "$DISTRO" == "alpine" ] || [ "$DISTRO" == "freebsd" ]; }; then
      sed -i "s|Allow 127.0.0.1|Allow $FIRST_QUESTION|" $TINYPROXY_CONFIG
      sed -i "s|Port 8888|Port $SECOND_QUESTION|" $TINYPROXY_CONFIG
    elif pgrep systemd-journal; then
      systemctl enable tinyproxy
      systemctl restart tinyproxy
    else
      service tinyproxy enable
      service tinyproxy restart
    fi
  }

  # restart the chrome service
  service-manager

  function install-tiny-proxy-manager() {
    if [ ! -f "$TINYPROXY_MANGER" ]; then
      echo "TinyProxy: true" >>$TINYPROXY_MANGER
    fi
  }

  install-tiny-proxy-manager

else

  # take user input
  function take-user-input() {
    echo "What do you want to do?"
    echo "   1) Uninstall"
    echo "   2) Update this script"
    until [[ "$USER_OPTIONS" =~ ^[1-2]$ ]]; do
      read -rp "Select an Option [1-2]: " -e -i 1 USER_OPTIONS
    done
    case $USER_OPTIONS in
    1)
      rm -f $TINYPROXY_MANGER
      rm -f $TINYPROXY_CONFIG
      if { [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "pop" ] || [ "$DISTRO" == "kali" ] || [ "$DISTRO" == "linuxmint" ]; }; then
        apt-get update && apt-get remove --purge tinyproxy -y
      elif { [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ]; }; then
        yum update -y && yum remove tinyproxy -y
      elif { [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "manjaro" ]; }; then
        pacman -Syu --noconfirm tinyproxy
      elif [ "$DISTRO" == "alpine" ]; then
        apk update
        apk add tinyproxy
      elif [ "$DISTRO" == "freebsd" ]; then
        pkg update
        pkg install tinyproxy
      fi
      ;;
    2)
      CURRENT_FILE_PATH="$(realpath "$0")"
      if [ -f "$CURRENT_FILE_PATH" ]; then
        curl -o "$CURRENT_FILE_PATH" $TINYPROXY_MANAGER_UPDATE
        chmod +x "$CURRENT_FILE_PATH" || exit
      fi
      ;;
    esac
  }

  # run the function
  take-user-input

fi
