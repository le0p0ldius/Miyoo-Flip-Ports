#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

controlfolder="/media/sdcard0/Ports/PortMaster"

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/littlegptracker"
CUR_TTY="/dev/tty0"
BINARY="lgpt"

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"
export LD_LIBRARY_PATH="/usr/lib/:/usr/lib/aarch64-linux-gnu/:/usr/lib32/:$LD_LIBRARY_PATH"
export XDG_CONFIG_HOME="$GAMEDIR"
export XDG_DATA_HOME="$GAMEDIR"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
printf "\033c" > $CUR_TTY
printf "Starting...\n" > $CUR_TTY

MULT_W=$(($DISPLAY_WIDTH / 320))
MULT_H=$(($DISPLAY_HEIGHT / 240))
NEW_MULT=$((MULT_W < MULT_H ? MULT_W : MULT_H))

if [ "$NEW_MULT" -le 0 ]; then
	NEW_MULT=1
fi

sed -i "s/SCREENMULT value='[0-9]'/SCREENMULT value='$NEW_MULT'/" "$GAMEDIR/config.xml"

if [ "$CFW_NAME" = "ArkOS" ]; then
	sed -E -i "s/FULLSCREEN value='(YES|NO)'/FULLSCREEN value='NO'/" "$GAMEDIR/config.xml"
else
	sed -E -i "s/FULLSCREEN value='(YES|NO)'/FULLSCREEN value='YES'/" "$GAMEDIR/config.xml"
fi

$GPTOKEYB "$BINARY" -c "$BINARY.gptk" &
./$BINARY

pm_finish
printf "\033c" > $CUR_TTY
