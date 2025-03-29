#!/bin/bash

set -eou pipefail


    ## ---Normal Settings---

# Lower and raise the volume by 20%, initial volume of music application starts at 60%
INITIAL_AUDIO_VOL=60  # Set this to x<=0 if you want to skip the initialization of music volume
AUDIO_VOL_DELTA=20

# Probably a good idea to make sure that Audio volume delta < Initial audio volume

    ## ---"Advanced" Settings---
TIME_DOWN=2 # Time it takes for volume to decrease; 1 = 0.1 sec
TIME_UP=10 # Time it takes for volume to increase; 1 = 0.1 sec

# Probably a good idea if time up and down evenly divides into audio vol delta

    ## ---End Settings---


AUDIO_VOL_DELTA_DOWN=$((AUDIO_VOL_DELTA / TIME_DOWN))
AUDIO_VOL_DELTA_UP=$((AUDIO_VOL_DELTA / TIME_UP))

MUSIC_PLAYER=$1  # Passed command line arg via musicPlayerExe.sh

# Make sure music player is running and set default volume if Initial volume is not set to at least 1.
if [ $AUDIO_VOL -gt 0 ] && pgrep -x "$MUSIC_PLAYER" >/dev/null; then
    pactl set-sink-input-volume "$AUD_ID" "$AUDIO_VOL"%
elif ! pgrep -x "$MUSIC_PLAYER" >/dev/null; then
    echo "$MUSIC_PLAYER is not running"
    exit 0
fi

# This gets the pactl Sink Input id number, using cli arg $1 as the search string
AUD_ID=$(pactl list sink-inputs | awk -v player="$MUSIC_PLAYER" '
        /Sink Input/ { id = $3 }
        $0 ~ "application.id = \"" player "\"" { print substr(id, 2) }
    ')

# Bool flag, is volume raised or lowered, default is true so volume can only decrease once from initial AUDIO_VOL
BOOL_FLAG=0

# Main loop: Run while MUSIC_PLAYER is running.
while pgrep -x $MUSIC_PLAYER >/dev/null; do

    # Total num of audio streams
    TOTAL_STREAMS=$(pactl list sink-inputs short | wc -l)
    
    # If more than one, we know there's another audio stream other than music player, so:
    if [ $BOOL_FLAG -eq 0 ] && [ $TOTAL_STREAMS -gt 1 ]; then
        # Lower music player audio stream by down delta
        for (( i=0; i<$TIME_DOWN; i++ ))
        do
            pactl set-sink-input-volume $AUD_ID -"$AUDIO_VOL_DELTA_DOWN"%
            sleep 0.1
        done
        BOOL_FLAG=1
    
    elif [ $BOOL_FLAG -eq 1 ] && [ $TOTAL_STREAMS -lt 2 ]; then # Otherwise raise the volume of audio player stream
        # Raise music player audio stream by up delta
        for (( i=0; i<$TIME_UP; i++ ))
        do
            pactl set-sink-input-volume $AUD_ID +"$AUDIO_VOL_DELTA_UP"%
            sleep 0.1
        done
        BOOL_FLAG=0

    fi
    sleep 0.75 # Avoid busy waiting 
done
