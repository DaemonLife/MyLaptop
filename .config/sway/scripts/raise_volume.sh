#!/bin/bash
pactl set-sink-volume 0 +5% && if [ $(echo $(pactl get-sink-volume 0 | grep -o "[^ ,]\+%" | head -n 1) | sed -r 's/%//g') -gt 100 ]; then pactl set-sink-volume 0 100%; fi
