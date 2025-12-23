#!/bin/bash
# Copyright (C) 2025 Oscar Josue Avila Gutierrez (ojag95)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# --- CONFIGURACIÓN ---
DEFAULT_WALLPAPER="/home/oscar/Imágenes/Wallpapers/roberto-shumski-e2rlqUNDzms-unsplash.jpg"
# Directorio temporal
TMP_DIR="/tmp"
# ---------------------

LAST_ART_URL=""
CURRENT_COVER_FILE=""

set_wallpaper() {
    local img_path="$1"
    
    # Script para KDE Plasma
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

echo "Iniciando monitor v2 (Anti-Caché)..."

while true; do
    # Buscamos solo reproductores en estado Playing
    PLAYER=$(playerctl -l 2>/dev/null | xargs -I{} sh -c 'if [ "$(playerctl -p {} status)" = "Playing" ]; then echo {}; fi' | head -n 1)
    
    if [ -n "$PLAYER" ]; then
        # HAY MÚSICA SONANDO
        NEW_ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)

        # Solo actuamos si la URL es diferente a la anterior
        if [ "$NEW_ART_URL" != "$LAST_ART_URL" ] && [ -n "$NEW_ART_URL" ]; then
            
            # Generamos un nombre único basado en la hora para engañar a KDE
            TIMESTAMP=$(date +%s%N)
            NEW_COVER_FILE="${TMP_DIR}/cover_${TIMESTAMP}.jpg"

            echo "🎵 Nueva portada detectada. Actualizando..."

            # Descargamos o Copiamos la imagen
            if [[ $NEW_ART_URL == http* ]]; then
                curl -s -o "$NEW_COVER_FILE" "$NEW_ART_URL"
            elif [[ $NEW_ART_URL == file://* ]]; then
                LOCAL_PATH=${NEW_ART_URL#file://}
                cp "$LOCAL_PATH" "$NEW_COVER_FILE"
            fi
            
            # Cambiamos el fondo
            if [ -f "$NEW_COVER_FILE" ]; then
                set_wallpaper "$NEW_COVER_FILE"
                
                # Limpieza: Borramos la portada anterior para no llenar /tmp
                if [ -n "$CURRENT_COVER_FILE" ] && [ "$CURRENT_COVER_FILE" != "$NEW_COVER_FILE" ]; then
                    rm -f "$CURRENT_COVER_FILE"
                fi
                
                CURRENT_COVER_FILE="$NEW_COVER_FILE"
                LAST_ART_URL="$NEW_ART_URL"
            fi
        fi

    else
        # NO HAY MÚSICA (Pausado o Detenido)
        if [ "$LAST_ART_URL" != "DEFAULT" ]; then
            echo "⏸️ Música detenida. Restaurando fondo original..."
            set_wallpaper "$DEFAULT_WALLPAPER"
            
            # Limpieza final
            if [ -n "$CURRENT_COVER_FILE" ]; then
                rm -f "$CURRENT_COVER_FILE"
                CURRENT_COVER_FILE=""
            fi
            
            LAST_ART_URL="DEFAULT"
        fi
    fi

    # Revisamos cada 1.5 segundos
    sleep 1.5
done
