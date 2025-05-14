#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

controlfolder="/media/sdcard0/Ports/PortMaster"
log "Control folder set to: $controlfolder"

log "Sourcing control.txt from: $controlfolder/control.txt"
source "$controlfolder/control.txt"

log "Calling get_controls function..."
get_controls

# Variables
GAMEDIR="/$directory/gunsoffury"
log "Game directory resolved to: $GAMEDIR"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"


# Assign gptokeyb and load the game
$GPTOKEYB "gmloadernext.aarch64" -c "guns.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64" >/dev/null
./gmloadernext.aarch64 -c gmloader.json

# Cleanup
pm_finish
