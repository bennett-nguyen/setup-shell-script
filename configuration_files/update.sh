#!/bin/bash

readonly CWD=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
readonly APPARMOR_PATH=$CWD"/APPARMOR"
readonly MKINITCPIO_PATH=$CWD/MKINITCPIO
readonly ZSH_PATH=$CWD/ZSH
readonly PACMAN_PATH=$CWD/PACMAN

# AppArmor
cat /etc/audit/auditd.conf > "${APPARMOR_PATH}/auditd.conf"
cat /etc/apparmor/parser.conf > "${APPARMOR_PATH}/parser.conf"

# mkinitcpio
cat /etc/mkinitcpio.conf > "${MKINITCPIO_PATH}/mkinitcpio.conf"

# pacman
cat /etc/pacman.conf > "${PACMAN_PATH}/pacman.conf"

# zsh
cat ~/.zshrc > "${ZSH_PATH}/.zshrc"
cat ~/.zshenv > "${ZSH_PATH}/.zshenv"