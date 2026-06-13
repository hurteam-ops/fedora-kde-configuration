#!/usr/bin/env bash
# Matugen reload — regenerate dynamic theme from current wallpaper
# Fedora KDE Edition

set -euo pipefail

WALLPAPER="${1:-}"

if [[ -z "$WALLPAPER" ]]; then
    # Try to get current KDE wallpaper
    if command -v qdbus6 &>/dev/null; then
        WALLPAPER=$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.currentConfigGroup "Wallpaper" "org.kde.plasma.image" "Image" 2>/dev/null || echo "")
    fi
    
    if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
        echo "Usage: matugen-reload /path/to/wallpaper.jpg"
        echo "Or set a wallpaper in KDE System Settings first."
        exit 1
    fi
fi

if ! command -v matugen &>/dev/null; then
    echo "Error: matugen is not installed."
    echo "Install it with: sudo dnf install matugen"
    exit 1
fi

echo "Generating theme from: $WALLPAPER"
matugen image "$WALLPAPER"

echo "Theme regenerated!"
echo "Open a new terminal to see the new colors."
