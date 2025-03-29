#!/bin/bash

set -eou pipefail

    ## ---Settings---

MUSIC_PLAYER="audacious"  # Name of music application, change for your specific music player. Double check by `pactl list sink-inputs | grep "application.id"` while your is active.

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

# Launch music player in the background.
$MUSIC_PLAYER &
AUD_PID=$!

# Start the monitoring script in the background. Sleep allows for the music player to actually start before volume manager.
sleep 0.5
"$PATH_TO_MUSIC_VOL_MANAGER" $MUSIC_PLAYER &
MONITOR_PID=$!

# Wait for either music player or the monitor script to exit
wait -n $AUD_PID $MONITOR_PID

# Kill whichever process is still running
kill $AUD_PID $MONITOR_PID 2>/dev/null || true