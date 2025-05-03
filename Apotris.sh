#!/bin/bash
# PORTMASTER: apotris.zip, Apotris.sh

controlfolder="/media/sdcard0/Ports/PortMaster"

source $controlfolder/control.txt

get_controls

GAMEDIR=/$directory/apotris

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "apotris" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./Apotris

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
