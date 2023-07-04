#!/bin/bash

# Funciones Principales

update_system (){
  sudo apt-get update 
  sleep 1s
  clear
  sudo apt-get upgrade -y
  sleep 1s
  clear
  sudo aptitude safe-upgrade -y
}

install_nvim (){
  echo -e "instalando Neovim \nEspera un momento..."
  wget "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage" -O /tmp/nvim
  chmod +x /tmp/nvim
  sudo chown root:root /tmp/nvim
  sudo mv /tmp/nvim /usr/bin/
  mkdir -p ~/.config/nvim
}

install_vscode (){
  echo -e "Instalando Visual Studio Code \nEspera un momento"
  wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O /tmp/vscode.deb
  clear
  sudo apt-get install /tmp/vscode.deb -y
  clear
  rm -rf /tmp/vscode.deb
}

install_vscode_extensions (){
  code --install-extension dbaeumer.vscode-eslint
  sleep 1s
  clear
  code --install-extension formulahendry.auto-close-tag
  sleep 1s
  clear
  code --install-extension formulahendry.auto-rename-tag
  sleep 1s
  clear
  code --install-extension MS-CEINTL.vscode-language-pack-es
  sleep 1s
  clear
  code --install-extension ritwickdey.LiveServer
  sleep 1s
  clear
  code --install-extension esbenp.prettier-vscode
  sleep 1s
  clear
  code --install-extension PKief.material-icon-theme
  sleep 1s
  clear
  code --install-extension eamodio.gitlens
  sleep 1s
  clear
  code --install-extension unthrottled.doki-theme
  sleep 1s
  clear
  code --install-extension adpyke.codesnap
  sleep 1s
  clear
}

# Limpia pantalla
clear

#Bienvenida
welcome (){
  echo -e "\e[0;32mBienvenido al instalador de entorno de desarrollo :3 \nEste script hara la configuracion completa de todo lo necesario. \nPor favor estar atento a las instrucciones que se te pidan."
  sleep 3s
  clear
  echo -e "Actualizando... \nPor favor espara un momento."
  sleep 1s
  update_system
  clear
}

# Editor
code_editor (){
  echo "¿Quieres usar neovim o vscode? [nvim / vscode]"
  read -p "---->: " dev_env
  clear
  if [[ $dev_env == *nvim* ]]
    then
      install_nvim
    elif [[ $dev_env == *vscode* ]]
      then
        install_vscode
        install_vscode_extensions
  fi
}

welcome
code_editor
