#!/bin/bash

# Change to your preferred installation directory
GAMEDIR="${HOME}/Games/Warframe"

WINE=${WINE:-wine64}
export WINEARCH=${WINEARCH:-win64}
export WINEDEBUG=${WINEDEBUG:--all}
export WINEPREFIX=$GAMEDIR

echo "*************************************************"
echo "Creating wine prefix and performing winetricks."
echo "*************************************************"

winetricks -q vcrun2015 vcrun2013 devenum xact xinput quartz win7

echo "*************************************************"
echo "Creating warframe directories."
echo "*************************************************"
mkdir -p ${GAMEDIR}/drive_c/Program\ Files/Warframe/
mkdir -p ${GAMEDIR}/drive_c/users/${USER}/Local\ Settings/Application\ Data/Warframe

echo "*************************************************"
echo "Copying warframe files."
echo "*************************************************"
cp -R * ${GAMEDIR}/drive_c/Program\ Files/Warframe/ 

cd ${GAMEDIR}/drive_c/Program\ Files/Warframe/
chmod a+x updater.exe
chmod a+x updater.sh
mv EE.cfg ${GAMEDIR}/drive_c/users/${USER}/Local\ Settings/Application\ Data/Warframe/EE.cfg

echo "*************************************************"
echo "Applying warframe wine prefix registry settings."
echo "*************************************************"
sed -i "s/%USERNAME%/"$USER"/g" wf.reg
$WINE regedit /S wf.reg

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
exec ./updater.sh
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
