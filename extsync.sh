#!/bin/zsh
# Run this from the Mac!

USER="danbarber"

MUSIC_DIR="/Users/${USER}/Music/Library/"
EXT_DIR="/Volumes/Tetraquark/Music/Library/"
EXCLUDE="${MUSIC_DIR}Scripts/exclude.txt"
PORT="2242"

# Sync music from this machine to the external drive
/usr/local/bin/rsync -rvt --exclude-from $EXCLUDE $MUSIC_DIR $EXT_DIR

# Sync back to the local machine
/usr/local/bin/rsync -rvt --exclude-from $EXCLUDE $EXT_DIR $MUSIC_DIR
