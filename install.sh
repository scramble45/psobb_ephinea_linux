#!/bin/bash

# Ephinea Phantasy Star Online - Blue Burst
# Installation Script for (GNU/Linux)
# https://ephinea.pioneer2.net/
# by r0r0
# specifically intended for use on Valve SteamDecks
# however should work for systems that have a normal Steam Install
# but also have flatpak

FILE=/usr/bin/steamtinkerlaunch
INSTALLER=https://files.pioneer2.net/Ephinea_PSOBB_Installer.exe
STL=https://github.com/frostworx/steamtinkerlaunch.git
PSOBB_BOX_ART=https://static.wikia.nocookie.net/phantasystar/images/b/bf/Psobb_box_segajp.jpg

welcome () {
    clear
    echo "Welcome to the Ephinea PSO Blue Burst (GNU/Linux) Installer"
    echo
    echo "Please close Steam fully before continuing!"
    echo "Now may be the time to plug-in a keyboard / mouse if using a Steam Deck"
    echo
    read -p "Are you ready to continue (y/n)?" choice
    case "$choice" in 
    y|Y ) echo "Starting installation";;
    * ) exit;;
    esac
}

killSteamThings () {
    clear
    echo "Trying to kill all things Steam related."
    pkill -f steam
}

depChecks () {
    clear
    if which flatpak >/dev/null; then
        echo
    else
        echo "Your missing flatpak, the installer cannot continue without it."
        exit
    fi

    # Currently we need to bring down SteamTinkerLaunch script and not use the flatpak version
    # because it is only aware of the FlatPak version of Steam, thats rather limiting so we will
    # just use the script directly.
    if [ -f "$HOME/Documents/steamtinkerlaunch/steamtinkerlaunch" ]; then
        echo "Steam Tinker Launch (STL) - already exists... skipping some steps"
    else 
        echo "Cloning Steam Tinker Launch repo to: $HOME/Documents/steamtinkerlaunch"
        git clone $STL $HOME/Documents/steamtinkerlaunch
        chmod +x $HOME/Documents/steamtinkerlaunch/steamtinkerlaunch
        echo "Creating directory for EN langauge config for (STL)"
        mkdir -p $HOME/.config/steamtinkerlaunch/lang
        echo "Copying over langauge config"
        cp -r $HOME/Documents/steamtinkerlaunch/lang/english.txt $HOME/.config/steamtinkerlaunch/lang/english.txt
        echo "STL has been installed"
    fi

    # Check if PeaZip is installed
    if flatpak list | grep PeaZip &> /dev/null; then
        echo "Found existing PeaZip installation..."
    else
        echo "PeaZip - flatpak needs to be installed to be able to extract game content"
        read -p "Do you want to continue with its installation (y/n)?" input
        case "$input" in
            y|Y ) flatpak install -y --noninteractive io.github.peazip.PeaZip ;;
            * ) exit;;
        esac
    fi

    # Check if Proton Tricks is installed
    if flatpak list | grep protontricks &> /dev/null; then
        echo "Found existing Proton Tricks installation..."
    else
        echo "Proton Tricks - flatpak is needed to install VC2019 easily which is required by Ephinea to do DLL injection for the client."
        read -p "Do you want to continue with its installation (y/n)?" input
        case "$input" in
            y|Y ) flatpak install -y --noninteractive com.github.Matoking.protontricks ;;
            * ) exit;;
        esac
    fi
}

# Main Installation Function
startInstall () {
    if [ -f "$HOME/Downloads/Ephinea_PSOBB_Installer.exe" ]; then
        echo "Installer already exists, skipping download."
    else 
        echo "Downloading Ephinea PSO Blue Burst..."
        echo
        curl --create-dirs -O --output-dir $HOME/Downloads $INSTALLER
    fi

    echo
    read -e -p "Enter where you want to install (defaults to: ~/Documents/psobb):" -i "$HOME/Documents/psobb" PSODIR
    echo
    echo "Extracting game content to: $PSODIR"

    # Run PeaZip to extract game content to specified directory
    flatpak run io.github.peazip.PeaZip -ext2simple $HOME/Downloads/Ephinea_PSOBB_Installer.exe $PSODIR &> /dev/null

    echo "Adding game to Steam, you will need to manually set which proton is used. GE-Proton should work well..."
    echo
    echo
    $HOME/Documents/steamtinkerlaunch/steamtinkerlaunch addnonsteamgame -an="Phantasy Star Online (Blue Burst)" -ep=$PSODIR/online.exe -lo="WINEDLLOVERRIDES='dinput8=n,b;d3d8=n,b' %command%"
    echo "---------------------------------------------------------------------------------"
    echo "We have to launch steam and you will need to set the compatibility to Proton"
    echo "Within Steam do the following:"
    echo "  - Right click on: Phantasy Star Online (Blue Burst)"
    echo "  - Click on COMPATIBILITY"
    echo "  - Check the box for: Force the use of a specific Steam Play compatibility tool"
    echo "  - Select GE-Proton or similar"
    echo "  - Exit the dialog box"
    echo "  - Click PLAY - the game options screen should open"
    echo "  - Click QUIT - from the Ephinea menu"
    echo "  - Fully exit Steam"
    echo
    echo "Fully exit steam and the installer script will continue."
    echo "Failing todo these step will result in a non-working game."
    echo "---------------------------------------------------------------------------------"
    echo

    read -p "Do you want to launch Steam (y/n)?" choice
    case "$choice" in 
    y|Y ) steam &> /dev/null;;
    * ) exit;;
    esac

    read -p "Have you fully closed Steam (y/n)?" choice
    case "$choice" in 
    y|Y ) echo;;
    * ) exit;;
    esac

    # Once Steam is close the rest of this can continue...
    # need to get the steam game id so we can do things in protontricks
    STEAMWINEID=$(flatpak run com.github.Matoking.protontricks -s "Phantasy Star Online (Blue Burst)" | grep -Po '(?<=\().*?(?=\))' |  tail -n1)
    
    if [[ $STEAMWINEID =~ ^[0-9]+$ ]]
    then
        clear
        echo "We found the installation..."
        echo "Trying to install VC2019 through Proton tricks"
        echo "Be sure to agree to any license agreement/EULA and click Install"
        flatpak run com.github.Matoking.protontricks $STEAMWINEID vcrun2019 &> /dev/null

        clear
        echo "==================================="
        echo "      Installation Complete!"
        echo "==================================="
        echo "If something didn't work you may try to just step through the commands passed in the script."
        echo
        echo "Please restart Steam"
        exit
    else
        echo "Something went wrong, make sure you read all the instructions and try again."
        echo "Or try to manually go through the script to debug why it failed."
        exit
    fi
}

welcome
killSteamThings
depChecks
startInstall