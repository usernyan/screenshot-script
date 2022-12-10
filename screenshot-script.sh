#!/bin/sh
#dependencies:
#	shotgun (for taking the screenshot)
#	hacksaw (for rectangle selection)
#	xclip (for copying to clipboard)
#	date (for default filenames)
#	xprop (for getting the focused window's id)

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
			echo "A screenshot-taking script."
			echo
			echo "Syntax: screenshot-script [-l (full|rect|focus)] [-s <dir>] [-n <name>]"
			echo "options:"
			echo "-l (full|rect|focus)"
			echo "    Choose selection type."
			echo "    full:    Fullscreen"
			echo "    rect:    Rectangle selection"
			echo "    focus:   The focused window"
			echo "-s <dir>"
			echo "    Save the screenshot to a file in <dir>."
			echo "-n <name>"
			echo "    Save the screenshot with the filename <name>. Requires -s"
			echo
			exit;;
		l) #selection type
			SEL_TYPE=$OPTARG
			case "$SEL_TYPE" in
				full|rect|focus|rect_in_win)
					;;
				*)
					INVALID_SEL_TYPE=1;;
			esac;;
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
	printf "Invalid selection type: %s\n" "$SEL_TYPE" >&2
	exit 1
fi

#Main
SELECTION_CANCELLED=0

if [ "$SEL_TYPE" = "rect" ]; then
	SELECTION="$(hacksaw -f "%i %g" 2> /dev/null)"
	SELECTION_CANCELLED="$?"
	if [ "$SELECTION_CANCELLED" -ne 0 ]; then
		exit;
	fi
	WIN_ID="$(printf '%s' "$SELECTION" | cut -d' ' -f1)"
	RECT_AREA="$(printf '%s' "$SELECTION" | cut -d' ' -f2)"
fi

if [ "$SEL_TYPE" = "focus" ]; then
	#This might rely on the window manager to set this property.
	WIN_ID="$(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)"
fi

if [ "$SEL_TYPE" = "rect_in_win" ]; then
	if ! WIN_ID="$(hacksaw -f "%i" 2> /dev/null)"; then
		exit;
	fi
	if ! RECT_AREA="$(hacksaw -f "%g" 2> /dev/null)"; then
		exit;
	fi
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
