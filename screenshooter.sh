#!/bin/sh
#dependencies:
#	shotgun
#	hacksaw
#	xclip
#	date

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






