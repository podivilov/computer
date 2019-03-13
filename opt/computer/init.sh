#!/bin/bash

# Step 1. Define global variables
CPATH="/opt/computer"

# Step 2. Wait while the startup sound being played
while pgrep -x "play" &> /dev/null; do
  sleep 0.1
done

# Step 2. Check if the internet connection available
ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` &> /dev/null && ONLINE="1" || ONLINE="0"; if [[ "$ONLINE" -eq "1" ]]; then aplay /usr/share/computer/sounds/greeting-online.wav &> /dev/null; else aplay /usr/share/computer/sounds/greeting-offline.wav &> /dev/null; fi

# Step 3. Generate new model
"$CPATH/tools/optimizer/linux/x86_64/pv_porcupine_optimizer" -r "$CPATH/resources/" -w computer -p linux -o "$CPATH" &> /dev/null && mv "$CPATH/computer_linux.ppn" "$CPATH/computer.ppn"

# Step 4. Tell the user that we are ready to go
if [[ "$ONLINE" -eq "1" ]]; then aplay /usr/share/computer/sounds/online.wav &> /dev/null; thunderbird & fi

# Step 5. Run the program
python3 "$CPATH" --keyword_file_paths "$CPATH/computer.ppn"
