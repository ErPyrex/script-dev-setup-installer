#!/bin/bash

# Funciones Principales


# Limpia pantalla
clear

#Bienvenida
welcome (){
  echo -e "\e[0;32mBienvenido al instalador de entorno de desarrollo :3 \nEste script hara la configuracion completa de todo lo necesario. \nPor favor estar atento a las instrucciones que se te pidan."
  sleep 3s
  clear
  echo -e "Actualizando... \nPor favor espara un momento."
  sleep 1s
  clear
}

# Editor
code_editor (){
  echo "¿Quieres usar neovim o vscode? [nvim / vscode]"
  read -p "---->: " dev_env
  clear
  if [[ $dev_env == *nvim* ]]
    then
      echo -e "instalando Neovim \nEspera un momento..."
      wget "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage" -O /tmp/nvim
      chmod +x /tmp/nvim
      sudo chown root:root /tmp/nvim
      sudo mv /tmp/nvim /usr/bin/
      mkdir -p ~/.config/nvim
    elif [[ $dev_env == *vscode* ]]
      echo -e "Instalando Visual Studio Code \nEspera un momento"
  fi
}

welcome
code_editor
