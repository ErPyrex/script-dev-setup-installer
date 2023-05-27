#!/bin/bash

# Actualizar el sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instalar git y zsh
sudo apt-get install git zsh -y

# Instalar kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sudo sh /dev/stdin launch=n

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
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Descargar el archivo vscode.deb
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O /tmp/vscode.deb

# Instalar el paquete usando apt
sudo apt install /tmp/vscode.deb -y
