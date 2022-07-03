#!/bin/sh -e
#dependencies:
#	shotgun
#	hacksaw
#	xclip
#	date

#TODO:
#	-r		Rectangle select, open hacksaw and click a window or draw a rectangle(done)
#	-s <dir>	Save to a file inside of the given directory (done)
#			If named file already exists, outputs to FILENAME(1) instead of overwriting
#	-n <name>	Manually set the file's name instead of using the date commmand (done)
#				ignored if -s is not specified.
#	-p		Reuse previous rectangle selection.
#where to save screenshots on linux by default? what format?
#What to do for multiple monitors?
#Can we use ffmpeg to record a section of the screen?
#What program can we use as a menu to visually crop screenshots after they're taken
#where to store temp files to be reused on the next script run? (planned -p option)

R_OPT=0
S_OPT=0
S_OUT_DIRECTORY=""
N_OPT=0
N_FILENAME=""

while getopts "hrs:n:" OPTION; do
	case $OPTION in
		h) #display help
			echo "Not implemented yet"
			exit;;
		r)
			R_OPT=1;;
		s)
			S_OPT=1
			S_OUT_DIRECTORY="$OPTARG";;
		n)
			N_OPT=1
			N_FILENAME="$OPTARG";;
		\?) #invalid options
			exit 1;;
	esac
done

RECT_SELECT=""
if [ $R_OPT -eq 1 ]; then
	RECT_SELECT=$(hacksaw -f "-i %i -g %g" 2> /dev/null)
fi

if [ $S_OPT -eq 0 ]; then
	shotgun $RECT_SELECT - | xclip -t 'image/png' -selection clipboard
else
	if [ $N_OPT -eq 1 ]; then
		FILENAME="$N_FILENAME"
	else
		FILENAME=$(date +%Y-%m-%d_%H:%M:%S:%N)
	fi
	shotgun $RECT_SELECT "${S_OUT_DIRECTORY}/${FILENAME}.png"
fi
