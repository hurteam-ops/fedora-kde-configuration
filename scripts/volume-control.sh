#!/usr/bin/env bash
# Volume control — Fedora KDE Edition
# Uses KDE's built-in tools with additional OSD feedback

set -euo pipefail

case "${1:-}" in
    up)
        pamixer --increase 5
        ;;
    down)
        pamixer --decrease 5
        ;;
    mute)
        pamixer --toggle-mute
        ;;
    mic-mute)
        pamixer --default-source --toggle-mute
        ;;
    *)
        echo "Usage: volume {up|down|mute|mic-mute}"
        exit 1
        ;;
esac

# Get current volume for OSD notification
VOLUME=$(pamixer --get-volume)
MUTED=$(pamixer --get-mute)

if [[ "$MUTED" == "true" ]]; then
    notify-send "Volume: Muted" -t 1000
else
    notify-send "Volume: ${VOLUME}%" -t 1000
fi
