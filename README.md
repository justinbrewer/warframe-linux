##  Not supported on Solus because for some stupid reason Solus doesn't have xterm when literally every other distro does.

## If you're getting crashes  
Report them on winehq. Nothing on my launcher can fix what wine breaks. All this does is set up a prefix and update/download/launch the game.  If you find a missing override or library, report it, but do not report crashes here without an answer.  


## Installation Instructions

Please be sure to install wine system dependencies. This can usually be achieved by installing wine on your system through your package manager.  Additional help can be found here:
[How to get out of Wine Dependency Hell](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/)

You will also need to install curl on your system for the updater to work.

Option A: Download Lutris. If you have lutris already, please make sure it is updated to version 0.4.14 or higher, as older versions had problems running batch scripts.  Next, run my Lutris install script for warframe:  
[Lutris 0.4.14](https://lutris.net/downloads/)  
[Warframe Install Script for Lutris](https://lutris.net/games/warframe/)  

Option B: Without Lutris:  
1. Install wine-staging 3.3 (or higher) for your linux distribution.  

2. Download a copy of my warframe wine wrapper repo and extract it somewhere: [warframe-linux-master](https://github.com/GloriousEggroll/warframe-linux/archive/master.zip)  

3. Open the extracted folder in a terminal and:  

```shell
  chmod a+x install.sh
```

```shell
  ./install.sh
```

An optional parameter may be passed to specify the target installation
directory. Run `./install.sh --help` to see all available options.

4. Launch the game via any of the following methods:  

```
  Applications>Games>Warframe
  Warframe desktop shortcut
  type "warframe" in a terminal
```

5. The launcher will open and run in an xterm terminal. It will then launch two "black boxes", one after another. This is Warframe.exe double checking for missed updates, and then optimizing the game cache. Once these launch they will close by themselves, and the game will launch, then the xterm window will close.  

## Uninstallation/Removal Instructions
This applies to non-lutris only: 

```shell
  ./uninstall.sh
```

## Technical notes:  
Known issues:
Local Reflections cause graphical glitches. Motion blurring is broken, Depth of Field causes stuttering and does not work correctly. Leave them off.  

These settings are disabled in the launcher to prevent crashing and for better performance:  

```
  64-bit mode
```

These settings are disabled by default to reduce gameplay stuttering and/or graphical glitches:  

```
  Vsync: OFF
  Local Reflections: OFF
  Local Reflection Blur: OFF
  Motion Blurring: OFF
  Depth of Field: OFF
```

You can set all other graphics settings as you wish.
