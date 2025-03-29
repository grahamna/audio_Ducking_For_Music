# Music Volume Manager

This project provides a simple script-based solution for automatically/dynamically adjusting the volume of a music player (e.g., Audacious) when other audio streams are playing using `pulseaudio` or `pipewire`. This behavior is known as 'Ducking'. It consists of two scripts:

1. **musicPlayerExe.sh** - Launches the music player and starts the volume manager. This file is designed to replace the shortcut for your music application.
2. **musicVolManager.sh** - Monitors audio streams and adjusts the music player's volume accordingly.

---

## Installation & Usage

### **Prerequisites**

Make sure you have the following dependencies installed:

- **pactl** (from `pulseaudio` or `pipewire`)
- Your music player of choice (default: `audacious`)

### **Setup**

1. Clone this repository or download/copy the scripts.

2. Edit `musicPlayerExe.sh` to specify your preferred music player:

   MUSIC\_PLAYER can be found by executing pactl list sink-inputs | grep "application.id"  while your music player of choice is running.

   ```bash
   MUSIC_PLAYER="audacious"
   PATH_TO_MUSIC_VOL_MANAGER="/PATH/TO/musicVolManager.sh"
   ```

3. Make both scripts executable:

   ```bash
   chmod +x /path/to/musicPlayerExe.sh
   chmod +x /path/to/musicVolManager.sh
   ```

4. Run the script or replace the executable short cut command for your music player:

   ```bash
   /path/to/musicPlayerExe.sh
   ```

---

## Script Details

### **musicPlayerExe.sh**

This script:

- Launches the music player in the background.
- Starts `musicVolManager.sh` to manage the volume.
- Ensures both scripts terminate when either the player or the manager exits.

### **musicVolManager.sh**

This script:

- Monitors the system's active audio streams.
- Lowers the music player's volume when another audio source starts playing.
- Restores the volume when the music player is the only audio source.

#### **Configuration Options**

Edit `musicVolManager.sh` to modify volume settings:

```bash
INITIAL_AUDIO_VOL=60    # Initial volume percentage
AUDIO_VOL_DELTA=20      # Volume adjustment percentage
TIME_DOWN=2             # Time in 0.1s steps for volume decrease
TIME_UP=10              # Time in 0.1s steps for volume increase
```

#### **How it Works**

1. The script identifies the music player's sink input using `pactl`.
2. It continuously monitors the number of active audio streams.
3. If another audio stream is detected, the music player's volume is  reduced.
4. When the music player is the only remaining stream, its volume is restored.

---

## Troubleshooting

- **Error: command not found**
  - Ensure that `pulseaudio` or `pipewire` is installed and running.
- **Music player not found**
  - Update `MUSIC_PLAYER` in `musicPlayerExe.sh` with the correct application name.
- **Volume adjustments not working**
  - Run `pactl list sink-inputs` and check if the music player's application ID is correctly detected. Debugging is easier if the script is launched from a terminal.

---

## Notes

- Using a systemd service to manage volume adjustments was considered but ultimately not implemented
- The script is designed to work with the Audacious music player, but it can be adapted to work with other players by changing the MUSIC_PLAYER variable in the scripts.
- The volume adjustments are done gradually in small steps to avoid abrupt changes in volume.
- The script uses pactl to interact with PulseAudio or PipeWire, so ensure these services are running correctly on your system.

---

## License

This script is open-source and available for modification and distribution under the MIT License.

---

## Author

Nathan Graham - Contributions are welcome!
