#!/bin/bash

set -x

if [[ `whoami` = "root" ]]; then
    echo "You're logged in as root! Please log in as a normal user to run this script!"
    exit 1
elif [[ $EUID -eq 0 ]]; then
    echo "Don't execute this file with root permissions."
    exit 1
fi

# Network Manager
echo "===== Setting up networking ====="
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service
nmcli device wifi list
echo -ne "Please choose a device to connect: "
read _device
nmcli device wifi connect _device --ask

case $? in
    0)
        echo "connected to device ${_device} sucessfully."
        ;;
    8)
        echo "NetworkManager.service doesn't seems to be running, is it installed?"
        exit 1
        ;;
    10)
        echo "Invalid device, try again."
        exit 1
        ;;
    *)
        echo "Error while connecting to device, refer to the exit code for further information: ${$?})"
        exit 1
        ;;
esac

# Update pacman
echo "====== Updating Pacman ======"
echo -ne "Please modify the pacman.conf file and then press enter to continue..."
read _wait
sudo pacman -Syu

# Install basic utilities
echo "===== Installing Basic Utilities ====="
sudo pacman -S git curl wget net-tools

# Setting up yay
echo "===== Setting up yay ====="
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd

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
sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio-lts.conf
echo -ne "Please modify the mkinitcpio.conf and the linux-lts.preset file to continue..."
read _wait
sudo pacman -S nvidia nvidia-utils nvidia-settings nvtop glxinfo nvidia-prime

# Fwupd
echo "====== Installing fwupd and checking for additional firmware updates ======"
sudo pacman -S fwupd intel-ucode
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
echo -ne "Please edit the kernel parameters then press Enter to continue..."
read _wait
echo -ne "Please edit the auditd.conf file and press Enter to continue..."
read _wait

touch ~/.config/autostart/apparmor-notify.desktop
tee ~/.config/autostart/apparmor-notify.desktop << EOF > /dev/null
[Desktop Entry]
Type=Application
Name=AppArmor Notify
Comment=Receive on screen notifications of AppArmor denials
TryExec=aa-notify
Exec=aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log
StartupNotify=false
NoDisplay=true
EOF

echo "Verifying AppArmor status..."
echo "Enabled: ${`aa-enabled`}"
sudo aa-status
echo "LOG: If you want to decrease boot time, enable cache profiles in /etc/apparmor/parser.conf"
sleep 3

# Bluetooth
echo "===== Installing Bluetooth protocol stack ====="
pacman -S bluez bluez-utils

# Ibus
echo "===== Installing IBus ====="
pacman -S ibus

echo "===== Installing IBus Bamboo ====="
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BambooEngine/ibus-bamboo/master/archlinux/install.sh)"

# Display Server
## Wayland
sudo pacman -S wayland xorg-xwayland xorg-xlsclients qt5-wayland glfw-wayland plasma-wayland-session

## X11
sudo pacman -S xorg

# Plasma
sudo pacman -S sddm sddm-kcm plasma-nm bluedevil plasma-desktop kscreen ark audiotube dolphin dolphin-plugins gwenview okular ksystemlog kclock kcalc kate kde-dev-utils kde-inotify-survey ktorrent kwalletmanager partitionmanager spectacle kcolorchooser kdiskfree keysmith kinfocenter kde-gtk-config

## Enable SDDM
sudo systemctl enable sddm.service

# Zshell
echo "===== Installing zsh ====="
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo -ne "Please enable zsh syntax highlighing then press Enter to continue..."
read _wait

# Reboot the machine
echo "LOG: Rebooting in 5 seconds..."
sleep 5
reboot