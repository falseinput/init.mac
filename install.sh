#!/bin/sh
set -eu

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_app_installed() {
    [[ -d "/Applications/$1.app" ]]
}

install_fonts() {
    url="$1"
    dest_dir="$2"

    tmp_zip="$(mktemp).zip"
    tmp_dir="$(mktemp -d)"

    mkdir -p "$dest_dir"

    curl -sSL -o "$tmp_zip" "$url"
    unzip -q "$tmp_zip" -d "$tmp_dir"
    cp "$tmp_dir"/*.ttf "$dest_dir"/

    rm -rf "$tmp_zip" "$tmp_dir"
}

append_config_line() {
    local config="$1"
    local file="$2"

    [[ -f "$file" ]] || return 0

    if ! grep -Fxq "$config" "$file"; then
        echo "$config" >> "$file"
    fi
}


ensure_supported_os() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        echo "Awesometools does not support $(uname -s) yet"
        exit
    fi
}

print_installation_status() {
    for s in "mise" "brew" "starship" "ghostty" "aerospace" "docker" "nvim" "code" "node" "pnpm" "python" "uv";
    do
        if is_installed $s; then
            echo "✅ $s is installed!"
        fi
    done
}

print_end_message() {
    print_installation_status
    echo ""
    echo "To enable tools in the current terminal session, run: \"source ~/.zshrc\""
}

ensure_supported_os

printf "Installing Nerd Fonts... "
install_fonts \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/0xProto.zip" \
  "$HOME/Library/Fonts"
echo "Done!"

if ! is_installed mise; then
    curl https://mise.run | sh
    append_config_line 'eval "$(mise activate zsh)"' "$HOME/.zshrc"
fi

if ! is_installed brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! is_installed starship; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    append_config_line 'eval "$(starship init zsh)"' "$HOME/.zshrc"
fi

if ! is_installed ghostty; then
    brew install --cask ghostty
    append_config_line "keybind = global:ctrl+\`=toggle_quick_terminal" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
fi


if ! is_installed aerospace; then
    brew install --cask nikitabobko/tap/aerospace
    
    #check if config file exists, if not download default config
    if [[ ! -f "$HOME/.aerospace.toml" ]]; then
        curl -o "$HOME/.aerospace.toml" "https://initmac.falseinput.com/configs/aerospace.toml"
    fi
fi

if ! is_installed docker; then
    curl -sS "https://desktop.docker.com/mac/main/arm64/Docker.dmg" -o "/tmp/Docker.dmg"
    cp -R "/Volumes/Docker/Docker.app" /Applications
    rm /tmp/Docker.dmg
fi

if ! is_installed nvim; then
    brew install neovim
    alled_config_line "alias n='nvim'" "$HOME/.zshrc"
fi

if ! is_installed code && ! is_app_installed "Visual Studio Code"; then
    brew install --cask visual-studio-code
    append_config_line 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' "$HOME/.zshrc"
fi

# Javascript
mise use --global node@lts >/dev/null 2>&1
mise use --global pnpm >/dev/null 2>&1

# Python
mise use --global python@latest >/dev/null 2>&1
mise use --global uv >/dev/null 2>&1

print_end_message
