#!/bin/bash

function usage() {
    cat <<EOF
usage: ./install.sh [-h|--help] [game-dir]

    game-dir  - Path to install. Defaults to '\$HOME/Games/Warframe'
    -h --help - Display this help message

Environment Variables:

The following environment variables will be preserved when later running the game:

    WINE      - Path to custom Wine executable. Defaults to 'wine64'
    WINEARCH  - Override Wine execution architecture. Currently, only 'win64' is supported.
    WINEDEBUG - Wine debugging settings. Defaults to '-all', all messages off.

EOF
}

if [ $# -gt 0 ]; then
    if [ $1 = "--help" ] || [ $1 = "-h" ]; then
	usage
	exit 0
    fi
fi

GAMEDIR=${1:-${HOME}/Games/Warframe}

WINE=${WINE:-wine64}
export WINEARCH=${WINEARCH:-win64}
export WINEDEBUG=${WINEDEBUG:--all}
export WINEPREFIX=$GAMEDIR

echo "*************************************************"
echo "Creating wine prefix and performing winetricks."
echo "*************************************************"

mkdir -p $GAMEDIR
winetricks -q vcrun2015 vcrun2013 devenum xact xinput quartz win7

echo "*************************************************"
echo "Applying warframe wine prefix registry settings."
echo "*************************************************"
$WINE regedit /S wf.reg

echo "*************************************************"
echo "Creating warframe directories."
echo "*************************************************"
mkdir -p ${GAMEDIR}/drive_c/Program\ Files/Warframe/
mkdir -p ${GAMEDIR}/drive_c/users/${USER}/Local\ Settings/Application\ Data/Warframe

echo "*************************************************"
echo "Copying warframe files."
echo "*************************************************"
cp EE.cfg ${GAMEDIR}/drive_c/users/${USER}/Local\ Settings/Application\ Data/Warframe/EE.cfg

cp -R updater.sh README.md \
    ${GAMEDIR}/drive_c/Program\ Files/Warframe/

pushd ${GAMEDIR}/drive_c/Program\ Files/Warframe/

cat > uninstall.sh <<EOF
#!/bin/bash

sudo rm -R /usr/bin/warframe /usr/share/pixmaps/warframe.png \\
           /usr/share/applications/warframe.desktop
rm -R \$HOME/Desktop/warframe.desktop $GAMEDIR
echo "Warframe has been successfully removed."
EOF

chmod a+x updater.sh
chmod a+x uninstall.sh

echo "*************************************************"
echo "Installing Direct X."
echo "*************************************************"
wget https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe
$WINE directx_Jun2010_redist.exe /Q /T:C:\dx9
$WINE dx9/dx9/DXSETUP.EXE /silent
rm -R dx9


echo "*************************************************"
echo "The next few steps will prompt you for shortcut creations. If root is required, please enter your root password when prompted."
echo "*************************************************"

echo "*************************************************"
echo "Creating warframe shell script"
echo "*************************************************"

cat > warframe.sh <<EOF
#!/bin/bash

export PULSE_LATENCY_MSEC=60
export __GL_THREADED_OPTIMIZATIONS=1
export MESA_GLTHREAD=TRUE

export WINE=$WINE
export WINEARCH=$WINEARCH
export WINEDEBUG=$WINEDEBUG
export WINEPREFIX=$WINEPREFIX

cd ${GAMEDIR}/drive_c/Program\ Files/Warframe/
exec ./updater.sh "\$@"
EOF

chmod a+x warframe.sh
sudo cp ${GAMEDIR}/drive_c/Program\ Files/Warframe/warframe.sh /usr/bin/warframe


read -p "Would you like a menu shortcut? y/n" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

	echo "*************************************************"
	echo "Creating warframe application menu shortcut."
	echo "*************************************************"

	sudo cp warframe.png /usr/share/pixmaps/

	cat > warframe.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Warframe
GenericName=Warframe
Exec=/usr/bin/warframe "\$@"
Icon=/usr/share/pixmaps/warframe.png
StartupNotify=true
Terminal=false
Type=Application
Categories=Application;Game
EOF

	sudo cp warframe.desktop /usr/share/applications/
fi

read -p "Would you like a desktop shortcut? y/n" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "*************************************************"
	echo "Creating warframe desktop shortcut."
	echo "*************************************************"
	cp /usr/share/applications/warframe.desktop ${HOME}/Desktop/
fi


echo "*************************************************"
echo "Installation complete! It is safe to delete this folder."
echo "*************************************************"
