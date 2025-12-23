#!/bin/bash

# --- CONFIGURATION ---
# DEFAULT_WALLPAPER Fallback Wallpaper when the music is stopped
# TMP_DIR Temporary directory to store image files
DEFAULT_WALLPAPER="/home/oscar/Imágenes/Wallpapers/roberto-shumski-e2rlqUNDzms-unsplash.jpg"
TMP_DIR="/tmp"

# Runtime Variables
LAST_ART_URL=""
CURRENT_COVER_FILE=""

set_wallpaper() {
    local img_path="$1"
    
    # KDE Plasma script
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allDesktops = desktops();
        for (i=0; i<allDesktops.length; i++) {
            d = allDesktops[i];
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
            d.writeConfig('Image', 'file://${img_path}');
        }
    "
}

echo "Starting audio monitor"

while true; do
    # We look for playback
    PLAYER=$(playerctl -l 2>/dev/null | xargs -I{} sh -c 'if [ "$(playerctl -p {} status)" = "Playing" ]; then echo {}; fi' | head -n 1)
    
    if [ -n "$PLAYER" ]; then
        #  There is music playing
        NEW_ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)

        # If new art url is different from the last one
        if [ "$NEW_ART_URL" != "$LAST_ART_URL" ] && [ -n "$NEW_ART_URL" ]; then
            
            # We generate a ne filename to avoid "caching" issues
            TIMESTAMP=$(date +%s%N)
            NEW_COVER_FILE="${TMP_DIR}/cover_${TIMESTAMP}.jpg"

            echo "New song detected. Updating..."

            # Downloading (or copying) the cover
            if [[ $NEW_ART_URL == http* ]]; then
                curl -s -o "$NEW_COVER_FILE" "$NEW_ART_URL"
            elif [[ $NEW_ART_URL == file://* ]]; then
                LOCAL_PATH=${NEW_ART_URL#file://}
                cp "$LOCAL_PATH" "$NEW_COVER_FILE"
            fi
            
            # Update Wallpaper
            if [ -f "$NEW_COVER_FILE" ]; then
                set_wallpaper "$NEW_COVER_FILE"
                
                # Cleaning /tmp for avoiding get out of RAM
                if [ -n "$CURRENT_COVER_FILE" ] && [ "$CURRENT_COVER_FILE" != "$NEW_COVER_FILE" ]; then
                    rm -f "$CURRENT_COVER_FILE"
                fi
                
                CURRENT_COVER_FILE="$NEW_COVER_FILE"
                LAST_ART_URL="$NEW_ART_URL"
            fi
        fi

    else
        # There is no music playback (Paused or stopped)
        if [ "$LAST_ART_URL" != "DEFAULT" ]; then
            echo "Music stopped. Restoring original wallpaper..."
            set_wallpaper "$DEFAULT_WALLPAPER"
            
            # Cleaning up
            if [ -n "$CURRENT_COVER_FILE" ]; then
                rm -f "$CURRENT_COVER_FILE"
                CURRENT_COVER_FILE=""
            fi
            
            LAST_ART_URL="DEFAULT"
        fi
    fi

    # We look every 1.5 seconds
    sleep 1.5
done
