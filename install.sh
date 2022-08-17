#!/bin/bash

# Ephinea Phantasy Star Online - Blue Burst
# Installation Script for (GNU/Linux)
# https://ephinea.pioneer2.net/
# by: r0r0
# Specifically intended for use on Valve SteamDeck
# however should work for systems with flatpak
# that have a normal non flatpak Steam Install

FILE=/usr/bin/steamtinkerlaunch
INSTALLER=https://files.pioneer2.net/Ephinea_PSOBB_Installer.exe
STL=https://github.com/frostworx/steamtinkerlaunch.git
ICON=https://cdn2.steamgriddb.com/file/sgdb-cdn/icon/0224cd598e48c5041c7947fd5cb20d53.png

welcome () {
    clear   
    echo
    echo "                                                    ▄░▀             "
    echo "  Welcome to the Ephinea PSO     ▀▄         ▄▄  ░▒▄     ▀▀          "
    echo "     (GNU/Linux) Installer        ▐▐  ▄▄   ▄▀ ▄                     "
    echo "                                  ▌▌▄█▓▓▓▀ ░ ▀ ▄                    "
    echo "                                  ▐▀▓▓█▌░▒▒      ░                  "
    echo "                            ▄▄▄▄ ▐▒▄▓█▒░▒▒    ░ ░  ░                "
    echo "                          ▓▄▄▄  ▒▀▀▀█▌▒░▒░ ▄▄     ░ ▐               "
    echo "                           ▀▀██▓▓▄▒▒▓█▒▒  ▐█ █▌      ▀              "
    echo "                             ▐██████▄▒▓▓▄  ▀▀▀        █             "
    echo "      Rappy Noises           ▐ █████████▓▒▓▄          ░▄            "
    echo "                             ▌ ██████████████▌        ░░▌           "
    echo "         by: r0r0            ▌ ░████▒█▀█▓██▓▒▒      ░░▒░░▒          "
    echo "                             ▌ ░█▒▒█▀▓███▓▓▓▓▒▒▒▒▓▒▒▒▒▒▒▒▐█         "
    echo "                             ▀▒█▒▀▄▄██▓▓▓▓▒▒▒▒▒▒▒▒▒    ░░░▀▄        "
    echo "     ▄▄▄                     ▐████▀░▒▒▒▒▒▒░▒  ░░       ░ ░░▀▄       "
    echo "  ▀▀▓▀▐█▓▓                   ▐█░░▒   ▀▒░░              ░░░   ▀▄     "
    echo " ▐▄▓█▓▀███▌                  █░░▒       ░               ▐░░░░░ ▒    "
    echo "  ▓ ░░░░░░  ▀ ▄             ▄▌░▒                          ▒░░░░░ ▀  "
    echo "▄▀ ░░▒▒█▒▒▄░      ▄       ▄▒░▒░                            ▀░░░░▒▒▒ "
    echo "▌░░▒▒▒▒▒▒▒▒▒▒▒▒░    ▓▄  ▄▒▒▄▒▒▒                              ▒░░▒▒▓ "
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

    # Check if SGDBoop is installed
    if flatpak list | grep SGDBoop &> /dev/null; then
        echo "Found existing SGDBoop installation..."
    else
        echo "SGDBoop - flatpak is needed to give you non-steam artwork for the game in Steam."
        read -p "Do you want to continue with its installation (y/n)?" input
        case "$input" in
            y|Y ) flatpak install -y --noninteractive com.steamgriddb.SGDBoop ;;
            * ) exit;;
        esac
    fi
}

# Main Installation Function
startInstall () {
    if [ -f "$HOME/Downloads/Ephinea_PSOBB_Installer.exe" ]; then
        echo "Installer already exists, skipping download."
    else
        echo
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
    # possible you may need to switch to using: /home/deck/stl/prefix/steamtinkerlaunch then the arguments below
    $HOME/Documents/steamtinkerlaunch/steamtinkerlaunch addnonsteamgame -an="Phantasy Star Online: Blue Burst" -ep=$PSODIR/online.exe -lo="WINEDLLOVERRIDES='dinput8=n,b;d3d8=n,b' %command%"
    echo "---------------------------------------------------------------------------------"
    echo "We have to launch Steam and you will need to set the compatibility to Proton"
    echo "------------------------------------------------------------------------"
    echo "We have to launch Steam:"
    echo
    echo "Within Steam do the following:"
    echo "  - Right click on: Phantasy Star Online (Blue Burst)"
    echo "  - Click on COMPATIBILITY"
    echo "  - Check: Force the use of a specific Steam Play compatibility tool"
    echo "  - Select GE-Proton or similar"
    echo "  - Exit the dialog box"
    echo "  - Click PLAY - the game options screen should open"
    echo "  - Click QUIT - from the Ephinea menu"
    echo "  - Fully exit Steam"
    echo
    echo "Fully exit Steam and the installer script will continue."
    echo "Failing todo these step will result in a non-working game."
    echo "------------------------------------------------------------------------"
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
    STEAMWINEID=$(flatpak run com.github.Matoking.protontricks -s "Phantasy Star Online: Blue Burst" | grep -Po '(?<=\().*?(?=\))' |  tail -n1)

    if [[ $STEAMWINEID =~ ^[0-9]+$ ]]
    then
        clear
        echo "We found the installation..."
        echo
        # we will go ahead and setup some artwork for the game
        # Steam Grid DB Artwork
        echo "Adding game artwork from SteamDB - select Phantasy Star: Blue Burst from list and press: (Okay)"
        echo "You will see this prompt four times. Repeat hitting: (Okay) all four times."
        flatpak run com.steamgriddb.SGDBoop sgdb://boop/grid/89252/nonsteam &> /dev/null
        flatpak run com.steamgriddb.SGDBoop sgdb://boop/grid/89255/nonsteam &> /dev/null
        flatpak run com.steamgriddb.SGDBoop sgdb://boop/logo/16664/nonsteam &> /dev/null
        flatpak run com.steamgriddb.SGDBoop sgdb://boop/hero/51229/nonsteam &> /dev/null

        echo "Saving game icon to: ${HOME}/Downloads, you will need to manually set it in Steam at a later point."
        curl --create-dirs -O --output-dir $HOME/Downloads $ICON

        echo "Trying to install VC2019 and Corefonts through Proton tricks"
        echo "Be sure to agree to any license agreement/EULA and click Install"
        echo "This may take a little bit, it may seem stuck, its probably not. Just be patient."
        flatpak run com.github.Matoking.protontricks $STEAMWINEID vcrun2019 corefonts win7 &> /dev/null

        reset
        echo "==================================="
        echo "      Installation Complete!"
        echo "==================================="
        echo "If something didn't work you may try to just step through the commands passed in the script."
        echo
        echo "You may want to change your font in the game options."
        echo "Please restart Steam"
        echo "Once restarted, launch the game and set your game options in the Ephinea launcher, eg. 1280x800 for Steam Deck"
        exit
    else
        echo "Something went wrong, make sure you read all the instructions and try again."
        echo "Or try to manually go through the script to debug why it failed."
        exit
    fi
}

welcome
depChecks
startInstall
