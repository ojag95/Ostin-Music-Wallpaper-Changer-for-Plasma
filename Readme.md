# Ostin Music Wallpaper Changer for Plasma


![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Arch%20Linux%20%7C%20KDE%20Plasma-1793d1)
![Bash](https://img.shields.io/badge/Language-Bash-4EAA25)

Un script ligero y eficiente para **KDE Plasma** que cambia dinámicamente tu fondo de pantalla mostrándote la portada del álbum de la canción que estás escuchando.

Cuando la música se detiene, el script restaura automáticamente tu fondo de pantalla original.

## Características

* **Universal:** Funciona con Spotify, YouTube Music (Navegadores), VLC, Elisa y cualquier reproductor compatible con MPRIS.
* **Anti-Caché:** Implementa un sistema de timestamping para obligar a KDE a refrescar la imagen instantáneamente al cambiar de canción.
* **Ultraligero:** Consumo de recursos prácticamente nulo (duerme el 99% del tiempo). Usa `/tmp` (RAM) para no desgastar el disco.
* **Inteligente:** Detecta automáticamente qué reproductor está sonando, ignorando los que están pausados.
* **Fallback:** Si pausas o cierras el reproductor, vuelve a tu wallpaper por defecto.

## Dependencias

Este script está diseñado para **Arch Linux** con entorno de escritorio **KDE Plasma**. Necesitas las siguientes herramientas:

* `playerctl`: Para controlar y leer metadatos de los reproductores.
* `curl`: Para descargar las portadas desde servicios web (Spotify, etc).
* `socat` / `qdbus`: Herramientas estándar de Plasma (generalmente ya instaladas).

### Instalación de dependencias en Arch Linux:

```bash
sudo pacman -S playerctl curl
```

> Nota: Si usas un navegador (Firefox/Chrome) para escuchar música, asegúrate de tener instalada la extensión "Plasma Integration" en el navegador y el paquete plasma-browser-integration en el sistema.

### Instalación y Uso

Descarga el script: Clona este repositorio o descarga el archivo plasmamusicwallpaperchanger.sh.


```bash
git clone [https://github.com/ojag95/Ostin-Music-Wallpaper-Changer-for-Plasma.git](https://github.com/ojag95/Ostin-Music-Wallpaper-Changer-for-Plasma.git)
cd NOMBRE_DEL_REPO
```

### Configura tu fondo por defecto: 
Abre el archivo plasmamusicwallpaperchanger.sh con tu editor de texto favorito y modifica la variable DEFAULT_WALLPAPER con la ruta de tu imagen favorita

### Ejecución

#### Dar permisos de ejecución

```bash
chmod +x ./plasmamusicwallpaperchanger
 ```

#### Ejecutar

```bash
./plasmamusicwallpaperchanger
```

### Iniciar automáticamente (Autostart)

Para que el script funcione siempre sin tener la terminal abierta:

* Abre Preferencias del Sistema (System Settings).

* Ve a Arranque y Apagado (Startup and Shutdown) -> Autoarranque (Autostart).

* Haz clic en + Añadir... -> Añadir Script de inicio de sesión.

* Selecciona la ruta donde guardaste plasmamusicwallpaperchanger.sh.

¡Listo! Ahora tu fondo de pantalla reaccionará a tu música cada vez que inicies sesión.

### Licencia

Este proyecto es software libre bajo la licencia GNU General Public License v3.0 (GPLv3). Eres libre de usarlo, modificarlo y distribuirlo bajo los mismos términos.

Consulta el archivo LICENSE para más detalles.

Hecho con ❤️ en Arch Linux.