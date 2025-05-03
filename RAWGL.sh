#!/bin/bash
# PORTMASTER: rawgl.zip, RAWGL.sh


# Set up logging
LOGFILE="/media/sdcard0/Ports/rawgl/portmaster_rawgl_debug.log"
exec 3>&1 1>>"$LOGFILE" 2>&1

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log() {
  echo "$(timestamp) - $*" >&1
}

log "========== Script Start =========="

controlfolder="/media/sdcard0/Ports/PortMaster"
log "Control folder set to: $controlfolder"

log "Sourcing control.txt from: $controlfolder/control.txt"
source "$controlfolder/control.txt"

log "Removing oga_controls from: /$directory/rawgl/oga_controls"
rm -f "/$directory/rawgl/oga_controls"

log "Calling get_controls function..."
get_controls

GAMEDIR="/$directory/rawgl"
log "Game directory resolved to: $GAMEDIR"

log "Changing to game directory: $GAMEDIR"
cd "$GAMEDIR"
log "Current working directory: $(pwd)"
log "Resolved GAMEDIR path: $GAMEDIR"
log "Contents of GAMEDIR:"
ls -l "$GAMEDIR" >&1

log "Setting tty1 permissions: chmod 666 /dev/tty1"
$ESUDO chmod 666 /dev/tty1

log "Launching gptokeyb with profile: rawgl"
$GPTOKEYB "rawgl" &
GPTOKEYB_PID=$!
log "gptokeyb launched with PID: $GPTOKEYB_PID"

if [[ $LOWRES == "Y" ]]; then
  rawgl_screen="--window=480x320"
  log "LOWRES enabled, using screen: $rawgl_screen"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  rawgl_screen="--window=854x480"
  log "Odroid Go 3 joystick detected, using screen: $rawgl_screen"
else
  rawgl_screen="--window=640x480"
  log "Default resolution, using screen: $rawgl_screen"
fi

log "Looking for .iso files in: $GAMEDIR/gamedata"
GAMEDATA="$(ls "$GAMEDIR/gamedata"/*.iso 2>/dev/null | head -1 || true)"
if [[ -z "$GAMEDATA" ]]; then
  GAMEDATA="$GAMEDIR/gamedata"
  log "No ISO found, falling back to directory: $GAMEDATA"
else
  log "Found ISO file: $GAMEDATA"
fi

log "Launching game with LD_LIBRARY_PATH=$GAMEDIR/libs"
log "Full command: ./rawgl $rawgl_screen --render=software --datapath=\"$GAMEDATA\" --language=us"
LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./rawgl $rawgl_screen --render=software --datapath="$GAMEDATA" --language=us 2>&1 | tee "$GAMEDIR/log.txt"

log "Game process exited. Killing gptokeyb with PID: $GPTOKEYB_PID"
$ESUDO kill -9 "$GPTOKEYB_PID" || log "Failed to kill gptokeyb (maybe already exited)"

log "Restarting oga_events"
$ESUDO systemctl restart oga_events &

log "Clearing tty1 output"
printf "\033c" >> /dev/tty1

log "========== Script End =========="
