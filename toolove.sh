#!/bin/sh
set -eu

is_installed() {
    command -v "$1" >/dev/null 2>&1
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
    for s in "mise" "brew" "starship" "ghostty"
    do
        if is_installed $s; then
            echo "✅ $s is installed!"
        fi
    done
}

print_end_message() {
    print_installation_status
    echo ""
    echo "To enable tools in current terminal session, run: \"source ~/.zshrc\""
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
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

if ! is_installed ghostty; then
    brew install --cask ghostty
fi


print_end_message
