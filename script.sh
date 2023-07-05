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

install_kitty (){
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
  clear
  sleep 1s
  sudo ln -s ~/.local/kitty.app/bin/kitty /usr/local/bin/
  usleep 500000
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  usleep 500000
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
  usleep 500000
  sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  usleep 500000
  sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
  usleep 500000
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/Desktop
  usleep 500000
  sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/Desktop/kitty*.desktop
  usleep 500000
  sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/Desktop/kitty*.desktop
  usleep 500000
  gio set ~/Desktop/kitty*.desktop metadata::trusted true
  usleep 500000
  chmod a+x ~/Desktop/kitty*.desktop
}

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
      continue
    elif [[ $dev_env == *vscode* ]]
      then
        install_vscode
        install_vscode_extensions
        continue
  fi
}

clear
welcome
read -p "¿Quieres instalar kitty console? [y / n]" kitty
if [[ $kitty == *y* ]]
  then
    install_kitty
    continue
  elif [[ $kitty == *n* ]]
    then
      continue
  else
    continue
  fi
code_editor
