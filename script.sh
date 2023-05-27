#!/bin/bash

# 显示进度条的函数
function show_progress() {
    local duration=$1
    local sleep_time=0.2
    local elapsed_time=0
    local progress_char="█"
    local progress_string=""
    local max_chars=50
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

# 检查PATH中是否有命令的功能
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 升级系统
sudo apt-get update && sudo apt-get upgrade -y || sudo yum update -y || sudo dnf update -y

# 安装git、zsh和build-essential
if command_exists apt-get; then
    sudo apt-get install git zsh build-essential -y
elif command_exists yum; then
    sudo yum install git zsh -y
elif command_exists dnf; then
    sudo dnf install git zsh -y
else
    echo "Could not find a compatible package manager (apt-get, yum or dnf). Manually install the git, zsh and build-essential packages."
    exit 1
fi

# 检查正在使用的是哪个shell
current_shell=$(basename "$SHELL")

# 向用户显示当前的外壳
echo "You are using $current_shell."

# 检查Zsh是否已经安装
if [[ "$current_shell" != "zsh" ]]; then
    if command_exists zsh; then
        # 将默认的shell改为Zsh
        if ! chsh -s "$(command -v zsh)"; then
            echo "There was an error changing the default shell to Zsh."
        else
            echo "The default shell has been changed to Zsh."
            echo "Please log out and log back in for the changes to take effect."
        fi
    else
        echo "Zsh is not installed. Please install it before changing the default shell."
    fi
else
    echo "You are already using Zsh as your default shell."
fi

# 安装kitty
(curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n) &&

# 用parrot.live显示动画
(curl -s parrot.live) &

# 等待背景任务的完成
wait

# 清洁屏幕
clear

# 在PATH中加入kitty
sudo ln -s ~/.local/kitty.app/bin/kitty /usr/local/bin/ || sudo ln -s ~/.kitty.app/bin/kitty /usr/local/bin/

# 为凯蒂创建桌面快捷方式
kitty_desktop_files=(~/.local/kitty.app/share/applications/kitty.desktop ~/.local/kitty.app/share/applications/kitty-open.desktop)
desktop_files_dir=~/.local/share/applications/
desktop_file_icon=/home/"$USER"/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png
kitty_exec=/home/"$USER"/.local/kitty.app/bin/kitty

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

# 安装Oh My Zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" &&

# 显示Oh My Zsh安装的进度条
show_progress 5

# 克隆Zsh插件库
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 安装 fzf
(git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install) &&

# 用parrot.live显示动画
(curl -s parrot.live) &

# 等待背景任务的完成
wait

# 清洁屏幕
clear

# 询问用户是否要安装Neovim（nvim）或Visual Studio Code（vscode）。
read -p "Do you want to install Neovim (nvim) or Visual Studio Code (vscode)? [nvim/vscode]: " option

if [[ "$option" == "vscode" ]]; then
    # 下载vscode.deb文件
    wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O /tmp/vscode.deb

    # 使用软件包管理器安装该软件包
    if command_exists apt-get; then
        sudo apt-get install /tmp/vscode.deb -y
    elif command_exists yum; then
        sudo yum install /tmp/vscode.deb -y
    elif command_exists dnf; then
        sudo dnf install /tmp/vscode.deb -y
    else
        echo "Could not find a compatible package manager (apt-get, yum or dnf). Manually install Visual Studio Code."
        exit 1
    fi

    # 安装Visual Studio Code的扩展
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension formulahendry.auto-close-tag
    code --install-extension formulahendry.auto-rename-tag
    code --install-extension MS-CEINTL.vscode-language-pack-es
    code --install-extension ritwickdey.LiveServer
    code --install-extension esbenp.prettier-vscode

elif [[ "$option" == "nvim" ]]; then
    # 下载nvim.appimage文件
    wget "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage" -O /tmp/nvim

    # 给予执行权限并将nvim移至/usr/bin
    chmod +x /tmp/nvim
    sudo chown root:root /tmp/nvim
    sudo mv /tmp/nvim /usr/bin/

    # 为nvim创建配置目录
    mkdir -p ~/.config/nvim
fi
