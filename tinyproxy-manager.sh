#!/bin/bash

# Require script to be run as root (or with sudo)
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
  # shellcheck disable=SC1090
  if [ -e /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO=$ID
    # shellcheck disable=SC2034
    DISTRO_VERSION=$VERSION_ID
  fi
}

# Check Operating System
dist-check

# Pre-Checks
function installing-system-requirements() {
  # shellcheck disable=SC2233,SC2050
  if ([ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]); then
    apt-get update && apt-get install curl -y
  fi
  # shellcheck disable=SC2233,SC2050
  if ([ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "rhel" ]); then
    yum update -y && yum install curl -y
  fi
  if [ "$DISTRO" == "arch" ]; then
    pacman -Syu --noconfirm curl
  fi
}

# Run the function and check for requirements
installing-system-requirements

if [ ! -f "/etc/tinyproxy/tinyproxy.conf" ]; then

# comments for the first question
function first-question() {
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
first-question


# comments for the first question
function second-question() {
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
second-question

function install-the-app() {
  # shellcheck disable=SC2233,SC2050
  if ([ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "DISTRO" == "raspbian" ]); then
    apt-get update && apt-get install tinyproxy -y
  fi
  # shellcheck disable=SC2233,SC2050
  if ([ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "DISTRO" == "rhel" ]); then
    yum update -y && yum install tinyproxy -y
  fi
  if [ "$DISTRO" == "arch" ]; then
    pacman -Syu --noconfirm tinyproxy
  fi
}

# run the function
install-the-app

# configure service here
function config-service() {
  if ([ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "arch" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "rhel" ]); then
    sed -i 's/Allow 127.0.0.1/Allow $FIRST_QUESTION/' /etc/tinyproxy/tinyproxy.conf
    sed -i 's/Port 8888/Port $SECOND_QUESTION/' /etc/tinyproxy/tinyproxy.conf
  fi
}

# run the function
config-service

function service-manager() {
  if pgrep systemd-journal; then
    systemctl enable tinyproxy
    systemctl restart tinyproxy
  else
    service tinyproxy enable
    service tinyproxy restart
  fi
}

# restart the chrome service
service-manager

else

# take user input
function take-user-input() {
    echo "What do you want to do?"
    echo "   1) Uninstall"
    echo "   2) Hello, World!"
    until [[ "$USER_OPTIONS" =~ ^[1-2]$ ]]; do
      read -rp "Select an Option [1-2]: " -e -i 1 USER_OPTIONS
    done
    case $USER_OPTIONS in
    1)
  # shellcheck disable=SC2233,SC2050
  if ([ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "DISTRO" == "raspbian" ]); then
    apt-get update && apt-get remove --purge tinyproxy -y
  fi
  # shellcheck disable=SC2233,SC2050
  if ([ "$DISTRO" == "fedora" ] || [ "$DISTRO" == "centos" ] || [ "DISTRO" == "rhel" ]); then
    yum update -y && yum remove tinyproxy -y
  fi
  if [ "$DISTRO" == "arch" ]; then
    pacman -Syu --noconfirm tinyproxy
  fi
  ;;
    2)
      echo "Hello, World!"
      ;;
    esac
}

# run the function
take-user-input

fi
