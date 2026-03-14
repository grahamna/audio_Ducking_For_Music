#!/bin/bash

set -euo pipefail
    ## ---Settings---

MUSIC_PLAYER="vlc"  # Name of music application, change for your specific music player. Double check by `pactl list sink-inputs | grep "application.icon_name"` while your player is active, or through program processes. This should be the "executable" available through the terminal

PATH_TO_MUSIC_VOL_MANAGER="/PATH/TO/musicVolManager.sh" # This should point to musicVolManager.sh if musicVolManager.sh is not in the same directory as this script

    ## ---End Settings---
    
# Check Music Input for bad characters via Whitelist
if [[ ! "$MUSIC_PLAYER" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Invalid music player name. Exiting."
    exit 1
fi

# Check dependencies
if ! command -v pactl &> /dev/null; then
    echo "Error: pactl command not found."
    exit 1
fi

if ! command -v "$MUSIC_PLAYER" &> /dev/null; then
    echo "Error: Music player ($MUSIC_PLAYER) not found."
    exit 1
fi

# Launch music player in the background.
"$MUSIC_PLAYER" &

# Start the monitoring script in the background. Sleep allows for the music player to actually start before volume manager.
sleep 0.35
# musicVolManager.sh must be in the same directory as this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/musicVolManager.sh" ]]; then
    "$SCRIPT_DIR/musicVolManager.sh" "$MUSIC_PLAYER"
else # or musicVolManager.sh must be defined in PATH_TO_MUSIC_VOL_MANAGER via 'settings'
    "$PATH_TO_MUSIC_VOL_MANAGER" "$MUSIC_PLAYER"
fi
