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

# Probably a good idea if time up and down evenly divides into AUDIO_VOL_DELTA

    ## ---End Settings---


AUDIO_VOL_DELTA_DOWN=$((AUDIO_VOL_DELTA / TIME_DOWN))
AUDIO_VOL_DELTA_UP=$((AUDIO_VOL_DELTA / TIME_UP))

MUSIC_PLAYER=$1  # Passed command line arg via musicPlayerExe.sh

# Check for bad characters in input string against Whitelist
if [[ ! "$MUSIC_PLAYER" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Invalid music player name. Exiting."
    exit 1
fi

# This gets the pactl Sink Input id number (from object.serial) from it, using cli arg $1 as the search string
get_aud_id() {
    pactl list sink-inputs | awk -v icon="$MUSIC_PLAYER" '
    /^Sink Input/ {
        in_block = 1
        match_icon = 0
    }

    in_block && $0 ~ "application.icon_name = \"" icon "\"" {
        match_icon = 1
    }

    in_block && match_icon && /object.serial/ {
        gsub(/[^0-9]/, "", $3)
        print $3
        exit
    }

    /^$/ {
        in_block = 0
        match_icon = 0
    }
    '
}

MAX_TRIES=67    # ~20 sec
TRIES=0

AUD_ID=$(get_aud_id)

# Attempts to capture the music player's AUD_ID as long as the Music Player is running, and not timed out (20 seconds)
while pgrep -x "$MUSIC_PLAYER" >/dev/null; do

    AUD_ID=$(get_aud_id)

    [[ -n "$AUD_ID" ]] && break

    ((TRIES++))
    if (( TRIES >= MAX_TRIES )); then
        echo "Timed out waiting for $MUSIC_PLAYER sink-input"
        exit 1
    fi
    sleep 0.3
done

# Makes sure music player is running and set default volume if Initial volume is not set to at least 1.
if [ $AUDIO_VOL -gt 0 ] && pgrep -x "$MUSIC_PLAYER" >/dev/null; then
    pactl set-sink-input-volume "$AUD_ID" "$AUDIO_VOL"%
elif ! pgrep -x "$MUSIC_PLAYER" >/dev/null; then
    echo "$MUSIC_PLAYER is not running"
    exit 0
fi

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
            if ! pactl set-sink-input-volume $AUD_ID -"$AUDIO_VOL_DELTA_DOWN"%; then;
                # If the command fails, refresh AUD_ID and try again.
                AUD_ID=$(get_aud_id)
                pactl set-sink-input-volume $AUD_ID -"$AUDIO_VOL_DELTA_DOWN"%
            fi
            sleep 0.1
        done
        BOOL_FLAG=1
    
    elif [ $BOOL_FLAG -eq 1 ] && [ $TOTAL_STREAMS -lt 2 ]; then # Otherwise raise the volume of audio player stream
        # Raise music player audio stream by up delta
        for (( i=0; i<$TIME_UP; i++ ))
        do
            if ! pactl set-sink-input-volume $AUD_ID +"$AUDIO_VOL_DELTA_UP"% then;
                # If the command fails, refresh AUD_ID and try again.
                AUD_ID=$(get_aud_id)
                pactl set-sink-input-volume $AUD_ID +"$AUDIO_VOL_DELTA_UP"%
            fi
            sleep 0.1
        done
        BOOL_FLAG=0

    fi
    sleep 0.75 # Avoid busy waiting 
done
