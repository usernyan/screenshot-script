#!/bin/sh
#dependencies:
#	shotgun (for taking the screenshot)
#	hacksaw (for rectangle selection)
#	xclip (for copying to clipboard)
#	date (for default filenames)
#	xprop (for getting the focused window's id)

#options:
#	-l <selection_type>	The type of selection to make,
#				Can be full (default), rect, or focus
#				(planned: prev_rect, prev_type)
#	-s <directory>		Save to a file in the given directory
#	-n <file_name>		Set the filename saved by -s

INVALID_OPT=0
INVALID_SEL_TYPE=0

SEL_TYPE="full"

S_OPT=0
OUT_DIR=""

N_OPT=0
OUT_FILE=""

#Parse Options
while getopts "hl:s:n:" OPTION; do
	case "$OPTION" in
		h) #display help
			echo "Not implemented yet."
			exit;;
		l) #selection type
			SEL_TYPE=$OPTARG
			if ! printf %s "$SEL_TYPE" | grep -F -e "full" -e "rect" -e "focus" > /dev/null; then
				INVALID_SEL_TYPE=1
			fi;;
		s)
			S_OPT=1;
			OUT_DIR="$OPTARG";;
		n)
			N_OPT=1;
			OUT_FILE="$OPTARG";;
		\?) #invalid options
			INVALID_OPT=1;;
	esac
done

if [ $INVALID_OPT -eq 1 ]; then
	exit 1
fi

if [ $INVALID_SEL_TYPE -eq 1 ]; then
	printf "Invalid selection type: %s\n" "$SEL_TYPE"
	exit 1
fi

#Main

if [ "$SEL_TYPE" = "rect" ]; then
	SELECTION="$(hacksaw -f "%i %g" 2> /dev/null)"
	WIN_ID="$(printf '%s' "$SELECTION" | cut -d' ' -f1)"
	RECT_AREA="$(printf '%s' "$SELECTION" | cut -d' ' -f2)"
fi

if [ "$SEL_TYPE" = "focus" ]; then
	#This might rely on the window manager to set this property.
	WIN_ID="$(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)"
fi

if [ "$S_OPT" -eq 0 ]; then
	shotgun ${WIN_ID:+-i "$WIN_ID"} ${RECT_AREA:+-g "$RECT_AREA"} \
	- | xclip -t 'image/png' -selection clipboard
else
	if [ "$N_OPT" -eq 1 ]; then
		FILENAME="$OUT_FILE"
	else
		FILENAME=$(date +%Y-%m-%d_%H:%M:%S:%N)".png"
	fi
	shotgun ${WIN_ID:+-i "$WIN_ID"} ${RECT_AREA:+-g "$RECT_AREA"} \
	-- "${OUT_DIR:-.}/${FILENAME}"
fi
