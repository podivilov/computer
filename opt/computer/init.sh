#!/bin/bash

# Step 1. Define global variables
CPATH="/opt/computer"

# Step 2 Wait while the startup sound being played
while pgrep -x "play" &> /dev/null; do
  sleep 0.1
done

# Step 3. Tell the user that we are currently setting up the system
aplay -q /usr/share/computer/sounds/beep.wav &
notify-send -i gnome-run "Один момент..."

# Check the internet connection
ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` &> /dev/null && ONLINE="1" || ONLINE="0"

if ! [[ "$ONLINE" == "0" ]]; then
  # Step 4. Connect to the TOR network
  sleep 0.75
  aplay -q /usr/share/computer/sounds/beep.wav &
  notify-send -i /usr/share/computer/icons/tor.png "Установка соединения..." "<b>Подключение к сети TOR...</b>"
  update-iptables-rules -l

  # Check if we are successfully connected to the TOR network
  if [[ "$?" -eq "0" ]]; then
    ip=$(curl -s "https://ipinfo.io/ip"); country=$(curl -s "https://ipinfo.io/country")
    aplay -q /usr/share/computer/sounds/information.wav &
    notify-send -i /usr/share/computer/icons/tor.png "Успех!" "<b>Соединение установлено\!</b>\n\nIP: $ip\nСтрана: $country"
  else
    aplay -q /usr/share/computer/sounds/information.wav &
    notify-send -i /usr/share/computer/icons/tor.png "Внимание!" "<b>Доступа к сети TOR нет\!</b>"
  fi
else
  aplay -q /usr/share/computer/sounds/error.wav &
  notify-send -i network-offline "Нет сети" "<b>Нет доступа к сети Интернет.</b>"
fi

# Step 5. Generate new model
sleep 0.75
aplay -q /usr/share/computer/sounds/beep.wav &
notify-send -i gnome-run "Подготовка окружения..." "<b>Генерация нейросети...</b>"
"$CPATH/tools/optimizer/linux/x86_64/pv_porcupine_optimizer" -r "$CPATH/resources/" -w computer -p linux -o "$CPATH" &> /dev/null && mv "$CPATH/computer_linux.ppn" "$CPATH/computer.ppn"

# Step 5.1. Setup environment and tell the user that we are ready to go
# thunderbird & while [[ -z $(wmctrl -l | grep "Thunderbird") ]]; do sleep 0.1; done; wmctrl -r "Thunderbird" -t 1; if [[ "$ONLINE" -eq "1" ]]; then mplayer /usr/share/computer/sounds/online.wav &> /dev/null; fi

# Step 6. Tell the user that we are ready to go
aplay -q /usr/share/computer/sounds/information.wav &
notify-send -i info "Всё!" "<b>Я готов к работе.</b>"

# Step 7. Run the program
python3 "$CPATH" --sensitivities 0.75 --keyword_file_paths "$CPATH/computer.ppn"
