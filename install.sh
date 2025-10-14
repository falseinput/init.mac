#!/bin/sh
# shellcheck disable=SC3010
# shellcheck disable=SC3043

set -eu

DEBUG=0
if [ "${1-}" = "--debug" ]; then
    DEBUG=1
    echo "Running in debug mode"
fi


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

run_command() {
    if [ "$DEBUG" = "1" ]; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
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

echo "
   ▘  ▘▗
██ ▌▛▌▌▜▘  ▛▛▌▀▌▛▘
██ ▌▌▌▌▐▖▗ ▌▌▌█▌▙▖

"


# Setup
ensure_supported_os
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

printf "Installing Nerd Fonts... "
install_fonts \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/0xProto.zip" \
  "$HOME/Library/Fonts"
echo "Done!"

if ! is_installed mise; then
    printf "Installing Mise... "
    run_command curl https://mise.run | sh
    echo "Done!"
fi

if ! is_installed brew; then
    printf "Installing Homebrew... "
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Done!"
fi

if ! is_installed starship; then
    printf "Installing Starship... "
    run_command curl -sS https://starship.rs/install.sh | sh -s -- --yes
    echo "Done!"
fi

if ! is_installed ghostty; then
    printf "Installing Ghostty... "
    run_command brew install --cask ghostty
    echo "Done!"
fi

if ! is_installed aerospace; then
    run_command brew install --cask nikitabobko/tap/aerospace
    
    #check if config file exists, if not download default config
    if [[ ! -f "$HOME/.aerospace.toml" ]]; then
        run_command curl -o "$HOME/.aerospace.toml" "https://initmac.falseinput.com/configs/aerospace.toml"
    fi
fi

if ! is_installed docker; then
    printf "Installing Docker... "
    run_command curl -sS "https://desktop.docker.com/mac/main/arm64/Docker.dmg" -o "/tmp/Docker.dmg"
    run_command cp -R "/Volumes/Docker/Docker.app" /Applications
    run_command rm /tmp/Docker.dmg
    echo "Done!"
fi

if ! is_installed nvim; then
    printf "Installing Neovim... "
    run_command brew install neovim
    echo "Done!"
fi

if ! is_installed code && ! is_app_installed "Visual Studio Code"; then
    printf "Installing Visual Studio Code... "
    run_command brew install --cask visual-studio-code
    echo "Done!"
fi

if ! is_app_installed "Firefox"; then
    printf "Installing Firefox... "
    run_command brew install --cask firefox
    echo "Done!"
fi

if ! is_app_installed "Google Chrome"; then
    printf "Installing Google Chrome... "
    run_command brew install --cask google-chrome
    echo "Done!"
fi

printf "Configuring shell... "
append_config_line "alias n=nvim" "$HOME/.zshrc"
append_config_line "export PATH=\"$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin\"" "$HOME/.zshrc"
append_config_line "keybind = global:ctrl+\`=toggle_quick_terminal" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
append_config_line 'eval "$(starship init zsh)"' "$HOME/.zshrc"
append_config_line 'eval "$(~/.local/bin/mise activate zsh)"' "$HOME/.zshrc"
echo "Done!"


# Javascript
if ! is_installed node; then
    printf "Installing NodeJS... "
    run_command mise use --global node@lts
    echo "Done!"
fi

if ! is_installed pnpm; then
    printf "Installing PNPM... "
    run_command mise use --global pnpm
    echo "Done!"
fi

# Python
if ! is_installed python; then
    printf "Installing Python... "
    run_command mise use --global python@latest
    echo "Done!"
fi

if ! is_installed uv; then
    printf "Installing uv... "
    run_command mise use --global uv
    echo "Done!"
fi

# Bash
if ! is_installed shellcheck; then
    printf "Installing ShellCheck... "
    run_command mise use --global shellcheck
    echo "Done!"
fi

if ! is_installed git; then
    printf "Installing Git... "
    run_command brew install git
    echo "Done!"
fi

if ! is_intalled git-delta; then
    printf "Installing git-delta... "
    run_command brew install git-delta
    echo "Done!"
    printf "Configuring git-delta... "
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    echo "Done!"
fi

# Final message
echo ""
echo "All done!"
echo ""
echo "To see changes immediately, run: source ~/.zshrc"
