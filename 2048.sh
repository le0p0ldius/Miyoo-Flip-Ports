#!/bin/bash

# Define log file in the same directory where the script is executed
LOGFILE="$(dirname "$0")/script.log"

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

# Set XDG_DATA_HOME if not already set
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
log "XDG_DATA_HOME set to $XDG_DATA_HOME"

# Define the control folder path
controlfolder="/media/sdcard0/App/PortMaster"
alternate_controlfolder="/media/sdcard0/App/PortMaster"

if [[ -d "$controlfolder" ]]; then
  log "Using control folder: $controlfolder"
elif [[ -d "$alternate_controlfolder" ]]; then
  log "Using alternate control folder: $alternate_controlfolder"
  controlfolder="$alternate_controlfolder"
else
  log "Neither $controlfolder nor $alternate_controlfolder found. Skipping sourcing of control files."
fi

# Source control.txt if it exists
if [[ -f "$controlfolder/control.txt" ]]; then
  log "Sourcing $controlfolder/control.txt"
  source "$controlfolder/control.txt"
else
  log "Warning: Missing file: $controlfolder/control.txt. Some features may not work as expected."
fi

# Source device_info.txt if it exists
if [[ -f "$controlfolder/device_info.txt" ]]; then
  log "Sourcing $controlfolder/device_info.txt"
  source "$controlfolder/device_info.txt"
else
  log "Warning: Missing file: $controlfolder/device_info.txt. Some features may not work as expected."
fi

# Call get_controls function if available
if command -v get_controls &>/dev/null; then
  log "Calling get_controls function"
  get_controls
  log "Successfully executed get_controls"
else
  log "Warning: get_controls function not found. Skipping."
fi


raloc="/media/sdcard0/RetroArch/"
raconf="/media/sdcard0/RetroArch/retroarch.cfg"

log "RetroArch location: $raloc, Config: $raconf"

# Define the game directory path
GAMEDIR="/$directory/2048"
if [[ -d "$GAMEDIR" ]]; then
  log "Game directory exists: $GAMEDIR"
else
  log "Warning: Game directory does not exist: $GAMEDIR. Game may not launch."
fi

# Start GPTOKEYB for controller mapping if available
if command -v "$GPTOKEYB" &>/dev/null; then
  log "Starting GPTOKEYB for RetroArch"
  $GPTOKEYB "retroarch" &
  log "Successfully started GPTOKEYB"
else
  log "Warning: GPTOKEYB command not found. Skipping."
fi

# Start RetroArch with the specified core and configuration if executable exists
if [[ -x "$raloc/retroarch" ]]; then
  log "Launching RetroArch with core: $GAMEDIR/2048_libretro.so.${DEVICE_ARCH}"
  $raloc/retroarch $raconf -L "$GAMEDIR/2048_libretro.so.${DEVICE_ARCH}" && log "RetroArch launched successfully" || log "Error: Failed to launch RetroArch"
else
  log "Error: RetroArch executable not found or not executable at $raloc/retroarch. Skipping launch."
fi
