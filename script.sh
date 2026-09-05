#!/usr/bin/env bash
# ==============================================================================
# Script de Configuración de Entorno de Desarrollo para Linux (Debian / Ubuntu / Mint)
# ==============================================================================

set -eo pipefail

LOG_FILE="/tmp/dev-setup-installer.log"
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"

# Colores y Formato
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

msg_banner() {
  echo -e "${CYAN}${BOLD}"
  echo "  ____                 ____       _               "
  echo " |  _ \  _____   __   / ___|  ___| |_ _   _ _ __  "
  echo " | | | |/ _ \ \ / /   \___ \ / _ \ __| | | | '_ \ "
  echo " | |_| |  __/\ V /     ___) |  __/ |_| |_| | |_) |"
  echo " |____/ \___| \_/     |____/ \___|\__|\__,_| .__/ "
  echo "                                           |_|    "
  echo -e "${RESET}"
  echo -e "${BOLD}Instalador automatizado de entorno de desarrollo${RESET}"
  echo -e "Registro de actividad: ${YELLOW}${LOG_FILE}${RESET}\n"
}

msg_step() {
  echo -e "\n${BOLD}${BLUE}==>${RESET} ${BOLD}$1${RESET}"
}

msg_ok() {
  echo -e "  ${GREEN}✓${RESET} $1"
}

msg_warn() {
  echo -e "  ${YELLOW}⚠${RESET} $1"
}

msg_error() {
  echo -e "  ${RED}✗${RESET} $1"
}

msg_info() {
  echo -e "  ${CYAN}ℹ${RESET} $1"
}

# Inicializar y mantener sudo activo
init_sudo() {
  msg_step "Comprobando privilegios de superusuario (sudo)..."
  if sudo -v; then
    # Mantener sudo vivo en segundo plano hasta que el script finalice
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_PID=$!
    trap 'kill "$SUDO_PID" 2>/dev/null || true' EXIT
    msg_ok "Privilegios sudo verificados."
  else
    msg_error "Se requieren privilegios sudo para ejecutar la instalación."
    exit 1
  fi
}

# 1. Actualización del sistema
update_system() {
  msg_step "Actualizando lista de paquetes y sistema (APT)..."
  sudo apt-get update -y >> "$LOG_FILE" 2>&1
  sudo apt-get upgrade -y >> "$LOG_FILE" 2>&1
  msg_ok "Sistema actualizado con éxito."
}

# 2. Paquetes esenciales
install_essentials() {
  msg_step "Instalando herramientas esenciales y dependencias base..."
  local pkgs=(
    curl
    wget
    git
    build-essential
    ca-certificates
    software-properties-common
    gnupg
    unzip
  )
  sudo apt-get install -y "${pkgs[@]}" >> "$LOG_FILE" 2>&1
  msg_ok "Herramientas esenciales instaladas."
}

# 3. Terminal Kitty
install_kitty() {
  msg_step "Configurando Kitty Terminal..."
  if command -v kitty &>/dev/null; then
    msg_info "Kitty ya se encuentra instalado. Saltando instalación base."
  else
    msg_info "Descargando e instalando Kitty mediante instalador oficial..."
    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n >> "$LOG_FILE" 2>&1
    sudo ln -sf "$HOME/.local/kitty.app/bin/kitty" /usr/local/bin/kitty
    sudo ln -sf "$HOME/.local/kitty.app/bin/kitten" /usr/local/bin/kitten
  fi

  # Integración de escritorio
  mkdir -p "$HOME/.local/share/applications"
  if [ -d "$HOME/.local/kitty.app" ]; then
    cp -f "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/" 2>/dev/null || true
    cp -f "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/" 2>/dev/null || true

    sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$HOME/.local/share/applications/kitty"*.desktop 2>/dev/null || true
    sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" "$HOME/.local/share/applications/kitty"*.desktop 2>/dev/null || true

    # Acceso directo en el escritorio si existe el directorio
    if [ -d "$DESKTOP_DIR" ]; then
      cp -f "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$DESKTOP_DIR/" 2>/dev/null || true
      sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$DESKTOP_DIR/kitty.desktop" 2>/dev/null || true
      sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" "$DESKTOP_DIR/kitty.desktop" 2>/dev/null || true
      chmod a+x "$DESKTOP_DIR/kitty.desktop" 2>/dev/null || true
      command -v gio &>/dev/null && gio set "$DESKTOP_DIR/kitty.desktop" metadata::trusted true 2>/dev/null || true
    fi
  fi
  msg_ok "Kitty Terminal configurado correctamente."
}

# 4. Zsh + Oh My Zsh + Plugins + fzf
install_zsh_stack() {
  msg_step "Instalando Zsh, Oh My Zsh y plugins..."
  sudo apt-get install -y zsh fzf >> "$LOG_FILE" 2>&1

  # Oh My Zsh (modo no interactivo)
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    msg_info "Instalando Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >> "$LOG_FILE" 2>&1
  else
    msg_info "Oh My Zsh ya está instalado."
  fi

  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$zsh_custom/plugins"

  # Plugin zsh-autosuggestions
  if [ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]; then
    msg_info "Clonando plugin zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" >> "$LOG_FILE" 2>&1
  fi

  # Plugin zsh-syntax-highlighting
  if [ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]; then
    msg_info "Clonando plugin zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting" >> "$LOG_FILE" 2>&1
  fi

  # Configurar plugins en .zshrc
  if [ -f "$HOME/.zshrc" ]; then
    if grep -q "^plugins=" "$HOME/.zshrc"; then
      sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)/' "$HOME/.zshrc"
    else
      echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf)" >> "$HOME/.zshrc"
    fi
  fi

  # Establecer Zsh como shell predeterminada si el usuario no la tiene
  local zsh_path
  zsh_path="$(which zsh 2>/dev/null || true)"
  if [ -n "$zsh_path" ] && [ "$SHELL" != "$zsh_path" ]; then
    msg_info "Cambiando shell por defecto a zsh..."
    sudo chsh -s "$zsh_path" "$USER" >> "$LOG_FILE" 2>&1 || true
  fi

  msg_ok "Zsh, Oh My Zsh, plugins y fzf configurados."
}

# 5. Visual Studio Code + Extensiones
install_vscode() {
  msg_step "Instalando Visual Studio Code y extensiones..."
  if command -v code &>/dev/null; then
    msg_info "VS Code ya se encuentra instalado. Procediendo a extensiones..."
  else
    local deb_path="/tmp/vscode.deb"
    msg_info "Descargando paquete oficial de VS Code (.deb)..."
    wget -q --show-progress "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O "$deb_path"
    msg_info "Instalando paquete..."
    sudo apt-get install -y "$deb_path" >> "$LOG_FILE" 2>&1
    rm -f "$deb_path"
  fi

  if command -v code &>/dev/null; then
    local extensions=(
      "dbaeumer.vscode-eslint"
      "formulahendry.auto-close-tag"
      "formulahendry.auto-rename-tag"
      "MS-CEINTL.vscode-language-pack-es"
      "ritwickdey.LiveServer"
      "esbenp.prettier-vscode"
      "PKief.material-icon-theme"
      "eamodio.gitlens"
      "unthrottled.doki-theme"
      "adpyke.codesnap"
    )

    msg_info "Instalando extensiones recomendadas de VS Code..."
    for ext in "${extensions[@]}"; do
      echo -ne "   Instalando $ext... \r"
      code --install-extension "$ext" --force >> "$LOG_FILE" 2>&1 || msg_warn "No se pudo instalar $ext"
    done
    echo -e "\033[K"
  fi
  msg_ok "Visual Studio Code configurado con éxito."
}

# 6. Neovim (AppImage oficial + soporte FUSE)
install_neovim() {
  msg_step "Instalando Neovim..."
  if command -v nvim &>/dev/null; then
    msg_info "Neovim ya está instalado ($(nvim --version | head -n 1)). Actualizando/verificando..."
  fi

  # Soporte FUSE necesario para AppImages en Debian/Ubuntu/Mint recientes
  sudo apt-get install -y libfuse2t64 2>>"$LOG_FILE" || sudo apt-get install -y libfuse2 2>>"$LOG_FILE" || true

  local arch
  arch="$(uname -m)"
  local nvim_url
  if [ "$arch" = "x86_64" ]; then
    nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
  elif [ "$arch" = "aarch64" ]; then
    nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage"
  else
    msg_error "Arquitectura $arch no compatible directamente con el AppImage precompilado."
    return 1
  fi

  local tmp_nvim="/tmp/nvim.appimage"
  msg_info "Descargando última versión de Neovim..."
  curl -fsSL "$nvim_url" -o "$tmp_nvim"
  chmod +x "$tmp_nvim"
  sudo mv -f "$tmp_nvim" /usr/local/bin/nvim
  mkdir -p "$HOME/.config/nvim"

  msg_ok "Neovim instalado correctamente en /usr/local/bin/nvim."
}

# Menú interactivo con whiptail o fallback
select_modules_dialog() {
  if command -v whiptail &>/dev/null; then
    whiptail --title "Instalador de Entorno de Desarrollo" \
      --checklist "\nSelecciona los componentes con ESPACIO y confirma con ENTER:\n" 20 72 6 \
      "UPDATE"     "Actualizar el sistema (apt update && upgrade)" ON \
      "ESSENTIALS" "Herramientas básicas (git, curl, wget, build-essential)" ON \
      "KITTY"      "Terminal Kitty + accesos directos" ON \
      "ZSH"        "Zsh + Oh My Zsh + plugins + fzf" ON \
      "VSCODE"     "Visual Studio Code + extensiones populares" ON \
      "NVIM"       "Neovim (AppImage oficial más reciente)" OFF \
      3>&1 1>&2 2>&3
  else
    echo -e "${YELLOW}whiptail no encontrado. Se instalarán los componentes predeterminados.${RESET}"
    echo '"UPDATE" "ESSENTIALS" "KITTY" "ZSH" "VSCODE"'
  fi
}

show_help() {
  echo "Uso: $0 [OPCIONES]"
  echo ""
  echo "Opciones:"
  echo "  --all       Ejecuta la instalación completa de todos los módulos sin preguntar."
  echo "  --help, -h  Muestra este mensaje de ayuda."
  echo ""
}

main() {
  msg_banner

  # Manejo de banderas
  local auto_all=false
  if [ "${1:-}" = "--all" ]; then
    auto_all=true
  elif [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    show_help
    exit 0
  fi

  local selected_choices=""
  if [ "$auto_all" = true ]; then
    selected_choices='"UPDATE" "ESSENTIALS" "KITTY" "ZSH" "VSCODE" "NVIM"'
  else
    if ! selected_choices=$(select_modules_dialog); then
      echo -e "\n${YELLOW}Instalación cancelada por el usuario.${RESET}"
      exit 0
    fi
  fi

  if [ -z "$selected_choices" ]; then
    msg_warn "No se seleccionó ningún componente. Saliendo..."
    exit 0
  fi

  # Solicitar sudo una sola vez
  init_sudo

  # Ejecución según selección
  [[ "$selected_choices" =~ "UPDATE" ]]     && update_system
  [[ "$selected_choices" =~ "ESSENTIALS" ]] && install_essentials
  [[ "$selected_choices" =~ "KITTY" ]]      && install_kitty
  [[ "$selected_choices" =~ "ZSH" ]]        && install_zsh_stack
  [[ "$selected_choices" =~ "VSCODE" ]]     && install_vscode
  [[ "$selected_choices" =~ "NVIM" ]]       && install_neovim

  msg_step "Instalación completada"
  echo -e "  ${GREEN}${BOLD}¡Todo listo! Tu entorno de desarrollo ha sido configurado.${RESET}"
  echo -e "  Para aplicar cambios en la terminal, reinicia la sesión o abre una nueva ventana."
  echo -e "  Si quieres revisar el registro completo de la instalación: ${YELLOW}${LOG_FILE}${RESET}\n"
}

main "$@"
