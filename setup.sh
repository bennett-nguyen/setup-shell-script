#!/bin/bash

# Constants
readonly CWD=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
readonly APPARMOR_PATH=$CWD/configuration_files/APPARMOR
readonly MKINITCPIO_PATH=$CWD/configuration_files/MKINITCPIO
readonly ZSH_PATH=$CWD/configuration_files/ZSH
readonly PACMAN_PATH=$CWD/configuration_files/PACMAN

# Update pacman
echo "====== Updating Pacman ======"
echo "Replace existing pacman.conf?"
echo -ne "[y\n]: "
read _replace_pacman

if [[ $_replace_pacman = "y" ]]; then
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak
    sudo rm /etc/pacman.conf
    sudo cp "${PACMAN_PATH}/pacman.conf" /etc/pacman.conf
fi

sudo pacman -Syu

# Install basic utilities
echo "===== Installing Basic Utilities ====="
sudo pacman -S git curl wget net-tools

# Firewall
echo "====== Installing a firewall ======"
sudo pacman -S ufw
sudo systemctl enable ufw.service
sudo systemctl start ufw.service

sudo ufw default deny incoming  
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw limit 22/tcp

sudo ufw enable
echo "LOG: Verifying ufw status..."
sudo ufw status verbose
sleep 3

# Important drivers
echo "====== Installing drivers ======"
sudo pacman -S libinput

# NVIDIA Drivers
echo "===== Installing Nvidia drivers ====="
sudo pacman -S nvidia nvidia-utils nvidia-settings nvtop glxinfo nvidia-prime
echo "Replace existing mkinitcpio.conf file?"
echo -ne "[y/n]: "
read _replace_existing_mkinitcpio

if [[ $_replace_existing_mkinitcpio = "y" ]]; then
    sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
    sudo rm /etc/mkinitcpio.conf
    sudo cp "${MKINITCPIO_PATH}/mkinitcpio.conf" /etc/mkinitcpio.conf
fi

# Fwupd
echo "====== Installing fwupd and checking for additional firmware updates ======"
sudo pacman -S fwupd udisks intel-ucode
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update

mkinitcpio -P

# AppArmor
sudo pacman -S apparmor audit python-psutil python-notify2
sudo systemctl enable apparmor.service
sudo systemctl enable auditd.service
sudo systemctl start apparmor.service
sudo systemctl start auditd.service 

echo "lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
echo "Replace existing auditd.conf file?"
echo -ne "[y/n]: "
read _replace_auditd

if [[ $_replace_auditd = "y" ]]; then
    sudo cp /etc/audit/auditd.conf /etc/audit/auditd.conf.bak
    sudo rm /etc/audit/auditd.conf
    sudo cp "${APPARMOR}/auditd.conf" /etc/audit/auditd.conf
fi 

echo -ne "Please edit the kernel parameters then press Enter to continue..."
read _wait

if [[ $_cache_profiles_decision = "y" ]]; then
    sudo cp /etc/apparmor/parser.conf /etc/apparmor/parser.conf.bak
    sudo rm /etc/apparmor/parser.conf
    sudo cp "${APPARMOR_PATH}/parser.conf" /etc/apparmor/parser.conf
fi

echo "Verifying AppArmor status..."
echo "Enabled:"`aa-enabled`
sudo aa-status
echo "Enable cache profiles?"
echo -ne "[y/n]: "
read _cache_profiles_decision


# Bluetooth
echo "===== Installing Bluetooth protocol stack ====="
pacman -S bluez bluez-utils

# Ibus
echo "===== Installing IBus ====="
pacman -S ibus

# Zshell
echo "===== Installing zsh ====="
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sudo chsh -s `which zsh`
cp "{$ZSH_PATH}/*" ~/

# Display
echo "Do you want to install a display manager?"
echo -ne "[y/n]: "
read _install_display_manager

if [[ $_install_display_manager = "y" ]]; then
    sudo sh "${CWD}/display.sh"
fi

# Reboot the machine
echo "LOG: Rebooting in 5 seconds..."
sleep 5
reboot