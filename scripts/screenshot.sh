#!/usr/bin/env bash
# Screenshot utility — Fedora KDE Edition
# Uses Spectacle (KDE's built-in screenshot tool) with options

set -euo pipefail

case "${1:-}" in
    area)
        spectacle --region --background --nonotify --output "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png" 2>/dev/null || \
        spectacle -r -b -n -o "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
    full)
        spectacle --fullscreen --background --nonotify --output "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png" 2>/dev/null || \
        spectacle -f -b -n -o "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
    screen)
        spectacle --current --background --nonotify --output "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png" 2>/dev/null || \
        spectacle -m -b -n -o "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"
        ;;
    *)
        echo "Usage: screenshot {area|full|screen}"
        exit 1
        ;;
esac

echo "Screenshot saved to $HOME/Pictures/Screenshots/"
