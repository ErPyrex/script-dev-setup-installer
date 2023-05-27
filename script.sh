#!/bin/bash

# Función para mostrar una barra de progreso
function show_progress() {
    local duration=$1
    local sleep_time=0.2
    local elapsed_time=0
    local progress_char="█"
    local progress_string=""
    local max_chars=$(tput cols)
    local max_ticks=$((duration / sleep_time))

    for ((i = 0; i <= max_chars; i++)); do
        progress_string+=" "
    done

    while ((elapsed_time <= duration)); do
        elapsed_ticks=$((elapsed_time / sleep_time))
        for ((i = 0; i <= elapsed_ticks; i++)); do
            progress_string="${progress_string:0:i}$progress_char${progress_string:i+1}"
        done
        printf "\r[%s] %s%%" "$progress_string" "$((elapsed_ticks * 100 / max_ticks))"
        sleep "$sleep_time"
        elapsed_time=$((elapsed_time + sleep_time))
    done

    printf "\n"
}

# Actualizar el sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instalar git, zsh y build-essential
sudo apt-get install git zsh build-essential -y

# Verificar qué shell se está utilizando
current_shell=$(basename "$SHELL")

# Mostrar la shell actual al usuario
echo "Estás usando $current_shell."

# Verificar si Zsh está instalado
if [[ "$current_shell" != "zsh" ]]; then
    if [[ -x "$(command -v zsh)" ]]; then
        # Cambiar la shell predeterminada a Zsh
        if ! chsh -s "$(command -v zsh)"; then
            echo "Hubo un error al cambiar la shell predeterminada a Zsh."
        else
            echo "Se ha cambiado la shell predeterminada a Zsh."
            echo "Por favor, cierra la sesión y vuelve a iniciarla para que los cambios surtan efecto."
        fi
    else
        echo "Zsh no está instalado. Por favor, instálalo antes de cambiar la shell predeterminada."
    fi
else
    echo "Ya estás utilizando Zsh como shell predeterminada."
fi

# Instalar kitty
(curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n) &

# Mostrar animación con parrot.live
(curl -s parrot.live) &

# Esperar a que las tareas en segundo plano finalicen
wait

# Limpiar la pantalla
clear

# Agregar kitty al PATH
sudo ln -s ~/.local/kitty.app/bin/kitty /usr/local/bin/

# Crear accesos directos al escritorio para kitty
kitty_desktop_files=(~/.local/kitty.app/share/applications/kitty.desktop ~/.local/kitty.app/share/applications/kitty-open.desktop)
desktop_files_dir=~/.local/share/applications/
desktop_file_icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png
kitty_exec=/home/$USER/.local/kitty.app/bin/kitty

for desktop_file in "${kitty_desktop_files[@]}"; do
    cp "$desktop_file" "$desktop_files_dir"
    sed -i "s|Icon=kitty|Icon=$desktop_file_icon|g" "$desktop_files_dir/$(basename "$desktop_file")"
    sed -i "s|Exec=kitty|Exec=$kitty_exec|g" "$desktop_files_dir/$(basename "$desktop_file")"
    gio set "$desktop_files_dir/$(basename "$desktop_file")" metadata::trusted true
    chmod a+x "$desktop_files_dir/$(basename "$desktop_file")"
done

cp "$desktop_files_dir/kitty.desktop" ~/Desktop
sed -i "s|Icon=kitty|Icon=$desktop_file_icon|g" ~/Desktop/kitty.desktop
sed -i "s|Exec=kitty|Exec=$kitty_exec|g" ~/Desktop/kitty.desktop
gio set ~/Desktop/kitty.desktop metadata::trusted true
chmod a+x ~/Desktop/kitty.desktop

# Instalar Oh My Zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" &
pid=$!

# Mostrar barra de progreso para la instalación de Oh My Zsh
show_progress 5

# Esperar a que la instalación de Oh My Zsh finalice
wait "$pid"

# Clonar los repositorios de plugins para Zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Instalar fzf
(git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install) &

# Mostrar animación con parrot.live
(curl -s parrot.live) &

# Esperar a que las tareas en segundo plano finalicen
wait

# Limpiar la pantalla
clear

# Preguntar al usuario si desea instalar Neovim (nvim) o Visual Studio Code (vscode)
read -p "¿Desea instalar Neovim (nvim) o Visual Studio Code (vscode)? [nvim/vscode]: " option

if [[ "$option" == "vscode" ]]; then
    # Descargar el archivo vscode.deb
    wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O /tmp/vscode.deb

    # Instalar el paquete usando apt
    sudo apt install /tmp/vscode.deb -y

    # Instalar las extensiones para Visual Studio Code
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension formulahendry.auto-close-tag
    code --install-extension formulahendry.auto-rename-tag
    code --install-extension MS-CEINTL.vscode-language-pack-es
    code --install-extension ritwickdey.LiveServer
    code --install-extension esbenp.prettier-vscode

elif [[ "$option" == "nvim" ]]; then
    # Descargar el archivo nvim.appimage
    wget "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage" -O /tmp/nvim

    # Dar permisos de ejecución y mover nvim a /usr/bin
    chmod +x /tmp/nvim
    sudo chown root:root /tmp/nvim
    sudo mv /tmp/nvim /usr/bin/

    # Crear directorio de configuración para nvim
    mkdir -p ~/.config/nvim
fi
