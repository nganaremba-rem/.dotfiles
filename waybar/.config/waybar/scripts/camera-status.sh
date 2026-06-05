#!/bin/bash
STATE_FILE="/tmp/.camera-state"
state="$(cat "$STATE_FILE" 2>/dev/null)"

# Camera physically in use: a process has a video device open
if [ -n "$(fuser /dev/video0 /dev/video1 2>/dev/null)" ]; then
    printf '{"text":"󰄀 In Use","tooltip":"Camera active — in use","class":"active"}\n'
    exit
fi

if [ "$state" = "off" ]; then
    printf '{"text":"󰄁 Off","tooltip":"Camera off","class":"off"}\n'
else
    printf '{"text":"󰄀","tooltip":"Camera on","class":"on"}\n'
fi
