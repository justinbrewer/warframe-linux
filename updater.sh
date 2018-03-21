#!/bin/bash
# exit on first error
set -e

# create folders if they don't exist
if [ ! -d "$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded" ]; then
  mkdir -p "$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"
fi

EXEPREFIX="$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"

WINE=${WINE:-wine64}
export WINEARCH=${WINEARCH:-win64}
export WINEDEBUG=${WINEDEBUG:--all}
export WINEPREFIX

# determine wich Warframe exe to run
#if [ "$WINEARCH" = "win64" ]; then
#	WARFRAME_EXE="$EXEPREFIX/Warframe.x64.exe"
#else
#	WARFRAME_EXE="$EXEPREFIX/Warframe.exe"
#fi

WARFRAME_EXE="$EXEPREFIX/Warframe.x64.exe"

#this is temporary until we can find out why both exes are getting corrupted and not launchable after closing
[ -f local_index.txt ] && sed -i "\#^/Warframe\(\.x64\)*\.exe.*#d" local_index.txt

function print_synopsis {
	echo "$0 [options]"
	echo ""
	echo "options:"
	echo "    --no-update         explicitly disable updating of warframe."
	echo "    --no-cache          explicitly disable cache optimization of warframe cache files."
	echo "    --no-launch         explicitly disable launching of warframe."
	echo "    -v, --verbose       print each executed command"
	echo "    -h, --help          print this help message and quit"
}

#############################################################
# default values
#############################################################
do_update=true
do_cache=true
start_game=true
verbose=false

#############################################################
# parse command line arguments
#############################################################
# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
	key="$1"
	case "$key" in
		--no-update)
		do_update=false
		;;
		--no-cache)
		do_cache=false
		;;
		--no-game)
		start_game=false
		;;
		-v|--verbose)
		verbose=true
		;;
		-h|--help)
		print_synopsis
		exit 0
		;;
		*)
		echo "Unknown option '$key'"
		print_synopsis
		exit 1
		;;
	esac
	# Shift after checking all the cases to get the next option
	shift
done

# show all executed commands
if [ "$verbose" = true ] ; then
	set -x
fi


#############################################################
# update game files
#############################################################
if [ "$do_update" = true ] ; then
	curl -A Mozilla/5.0 http://origin.warframe.com/index.txt.lzma | unlzma - > index.txt
	sort -o index.txt index.txt
	touch local_index.txt

	echo "*********************"
	echo "Checking for updates."
	echo "*********************"

	#create list of all files to download
	comm -2 -3 index.txt local_index.txt > updates.txt

	# sum up total size of updates
	TOTAL_SIZE=0
	while read -r line; do
		# get the remote size of the lzma file when downloading
		REMOTE_SIZE=$(echo $line | awk -F, '{print $2}' | sed 's/\r//')
		(( TOTAL_SIZE+=$REMOTE_SIZE ))
	done < updates.txt

	echo "*********************"
	echo "Downloading updates."
	echo "*********************"

	#currently downloaded size
	CURRENT_SIZE=0
	PERCENT=0
	while read -r line; do
		#get the raw filename with md5sum and lzma extension
		RAW_FILENAME=$(echo $line | awk -F, '{print $1}')
		#get the remote size of the lzma file when downloading
		REMOTE_SIZE=$(echo $line | awk -F, '{print $2}' | sed 's/\r//')
		#path to local file currently tested
		LOCAL_FILENAME="${RAW_FILENAME:0:-38}"
		LOCAL_PATH="$EXEPREFIX${LOCAL_FILENAME}"
		#URL where to download the latest file
		DOWNLOAD_URL="http://content.warframe.com$RAW_FILENAME"

		if [ -f local_index.txt ]; then
			#remove old local_index entry
			sed -i "\#^${LOCAL_FILENAME}#d" local_index.txt
		fi

		#show progress percentage for each downloading file
		echo "Total update progress: $PERCENT% Downloading: ${RAW_FILENAME:0:-38}"

		#download file and replace old file
		mkdir -p "$(dirname "$LOCAL_PATH")"
		curl -A Mozilla/5.0 $DOWNLOAD_URL | unlzma - > "$LOCAL_PATH"

		#update local index
		echo "$line" >> local_index.txt

		#update progress percentage
		(( CURRENT_SIZE+=$REMOTE_SIZE ))
		PERCENT=$(( ${CURRENT_SIZE}*100/${TOTAL_SIZE} ))
	done < updates.txt
	#print finished message
	echo "$PERCENT% ($CURRENT_SIZE/$TOTAL_SIZE) Finished downloads"

	# cleanup
	rm updates.txt
	rm index.txt
	sed -i '/^\s*$/d' local_index.txt
	sort -o local_index.txt local_index.txt

	# run warframe internal updater
	$WINE "$WARFRAME_EXE" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate
fi


#############################################################
# cache optimization
#############################################################
if [ "$do_cache" = true ] ; then
	echo "*********************"
	echo "Optimizing Cache."
	echo "*********************"
	$WINE "$WARFRAME_EXE"  -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/CacheDefraggerAsync /Tools/CachePlan.txt
fi


#############################################################
# actually start the game
#############################################################
if [ "$start_game" = true ] ; then

	echo "*********************"
	echo "Launching Warframe."
	echo "*********************"

	$WINE "$WARFRAME_EXE" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
fi
