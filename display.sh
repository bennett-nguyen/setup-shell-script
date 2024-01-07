# Display Server
echo "Which display server do you want to install?"
echo "1. Wayland \n2. X11\n3. Both\n4. Neither"
echo -ne "[1/2/3/4]: "
read _display_server_options

case $_display_server_options in
    1)
        sudo pacman -S wayland xorg-xwayland xorg-xlsclients qt5-wayland glfw-wayland plasma-wayland-session
        ;;
    2)
        sudo pacman -S xorg
        ;;
    3)
        sudo pacman -S wayland xorg-xwayland xorg-xlsclients qt5-wayland glfw-wayland plasma-wayland-session
        sudo pacman -S xorg
        ;;
    *)
        ;;
esac

# Plasma
echo "Do you want to install Plasma with SDDM and basic applications?"
echo -ne "[y/n]: "
read _decision_plasma

if [[ $_decision_plasma = "y" ]]; then
    sudo pacman -S sddm sddm-kcm plasma-nm bluedevil plasma-desktop kscreen ark audiotube dolphin dolphin-plugins gwenview okular ksystemlog kclock kcalc kate kde-dev-utils kde-inotify-survey ktorrent kwalletmanager partitionmanager spectacle kcolorchooser kdiskfree keysmith kinfocenter kde-gtk-config
    sudo systemctl enable sddm.service
fi