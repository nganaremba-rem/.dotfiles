#!/bin/bash
# Mic mute state
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
    printf '{"text":"󰍭 Muted","tooltip":"Microphone muted","class":"muted"}\n'
    exit
fi

# Mic in use: any active recording stream in PipeWire
if pactl list source-outputs 2>/dev/null | grep -q "Source Output #"; then
    printf '{"text":"󰍬 In Use","tooltip":"Microphone recording","class":"active"}\n'
else
    printf '{"text":"󰍬","tooltip":"Microphone on","class":"on"}\n'
fi
