# Configura tu entorno Linux de manera rápida

Script de automatización para configurar un entorno de desarrollo completo tras una instalación limpia o formateo. Pensado para distribuciones basadas en **Debian / Ubuntu / Linux Mint / Linux Lite**.

## Características

- 📋 **Menú interactivo:** Interfaz gráfica en terminal (TUI) con `whiptail` para seleccionar qué componentes instalar mediante casillas de verificación.
- ⚡ **Modo desatendido:** Flag `--all` para automatizar completamente la instalación en un solo comando.
- 📦 **Actualización del sistema:** Actualización segura de paquetes de APT sin bloqueos ni herramientas redundantes.
- 🛠️ **Herramientas esenciales:** `git`, `curl`, `wget`, `build-essential`, `ca-certificates`, etc.
- 🐱 **Terminal Kitty:** Descarga la versión oficial, crea symlinks en `/usr/local/bin` y genera accesos directos dinámicos en el lanzador y en el Escritorio (compatible con idiomas inglés y español vía `xdg-user-dir`).
- 🐚 **Zsh + Oh My Zsh:** 
  - Instalación desatendida de Oh My Zsh.
  - Plugins: `zsh-autosuggestions` y `zsh-syntax-highlighting`.
  - Herramienta de búsqueda difusa `fzf`.
  - Configuración automática del archivo `~/.zshrc` y cambio opcional de shell por defecto.
- 💻 **Visual Studio Code:**
  - Descarga e instalación del paquete oficial `.deb`.
  - Instalación automática de extensiones populares (ESLint, Prettier, GitLens, Temas, Icons, Live Server, CodeSnap, etc.).
- 🖋️ **Neovim:**
  - Descarga del AppImage oficial más reciente con detección de arquitectura (x86_64 / arm64).
  - Instalación y soporte automático para bibliotecas FUSE (`libfuse2` / `libfuse2t64`).
- 📝 **Registro de auditoría (Logs):** Toda la salida detallada se guarda en `/tmp/dev-setup-installer.log` manteniendo la terminal limpia y legible.

## Instrucciones de uso

### 1. Dar permisos de ejecución
```bash
chmod +x script.sh
```

### 2. Ejecutar con menú interactivo
```bash
./script.sh
```
*Usa las flechas del teclado y la barra espaciadora para marcar/desmarcar los componentes que deseas instalar, y presiona Enter para confirmar.*

### 3. Ejecución desatendida (instalar todo)
```bash
./script.sh --all
```

### 4. Ayuda
```bash
./script.sh --help
```
