#!/bin/bash

# Actualizar el sistema
sudo apt-get update && sudo apt-get upgrade -y

# Descargar el archivo vscode.deb
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O /tmp/vscode.deb

# Instalar el paquete usando apt
sudo apt install /tmp/vscode.deb
