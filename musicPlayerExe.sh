#!/bin/bash

set -eou pipefail

    ## ---Settings---

MUSIC_PLAYER="vlc"  # Name of music application, change for your specific music player. Double check by `pactl list sink-inputs | grep "application.icon_name"` while your is active, or through program processes. This should be the "executable" available through the terminal

PATH_TO_MUSIC_VOL_MANAGER="/PATH/TO/musicVolManager.sh" # This should point to musicVolManager.sh

    ## ---End Settings---


# Check dependencies
if ! command -v pactl &> /dev/null; then
    echo "Error: pactl command not found."
    exit 1
fi

if ! command -v $MUSIC_PLAYER &> /dev/null; then
    echo "Error: Music player ($MUSIC_PLAYER) not found."
    exit 1
fi

# Check Music Input for bad characters via Whitelist
if [[ ! "$MUSIC_PLAYER" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Invalid music player name. Exiting."
    exit 1
fi

# Launch music player in the background.
$MUSIC_PLAYER &


# Start the monitoring script in the background. Sleep allows for the music player to actually start before volume manager.
sleep 0.35
"$PATH_TO_MUSIC_VOL_MANAGER" $MUSIC_PLAYER