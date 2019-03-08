#!/bin/zsh
# Run this from the Mac!

USER="danbarber"

MUSIC_DIR="/Users/${USER}/Music/Library/"
REMOTE="danbarber@kimiko.local:/tokyo/media/music/"
EXCLUDE="${MUSIC_DIR}Scripts/exclude.txt"
# PORT="2242"

# Ensure any changes here are pushed to Asmodeus
/usr/local/bin/rsync -rvt --iconv=UTF8-MAC,UTF-8 --exclude-from $EXCLUDE $MUSIC_DIR $REMOTE
# /usr/local/bin/rsync -e "ssh -p $PORT" -rvt --iconv=UTF8-MAC,UTF-8 --exclude-from $EXCLUDE $MUSIC_DIR $REMOTE

# Get any new stuff from Asmodeus
/usr/local/bin/rsync -rvt --iconv=UTF8-MAC,UTF-8 --exclude-from $EXCLUDE $REMOTE $MUSIC_DIR
# /usr/local/bin/rsync -vvv -e "ssh -p $PORT" -rvt --iconv=UTF8-MAC,UTF-8 --exclude-from $EXCLUDE $REMOTE $MUSIC_DIR
