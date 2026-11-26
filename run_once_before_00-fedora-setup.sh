#!/usr/bin/env bash
set -euo pipefail

if ! grep -qi '^id=fedora' /etc/os-release; then
    echo "Skipping Fedora package setup (not running on Fedora)."
    exit 0
fi

if [ ! -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:duxlabs:dms.repo ]; then
    sudo dnf copr enable -y duxlabs/dms
fi

if [ ! -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:kaleedtc:mangowm.repo ]; then
    sudo dnf copr enable -y kaleedtc/mangowm
fi

PACKAGES=(
    # Compositor, shell, display manager, portals
    mangowm
    dms
    sddm
    xorg-x11-server-Xwayland
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    gnome-keyring
    adw-gtk3-theme
    qt6-qtimageformats
    kf6-kimageformats
    # Audio & laptop hardware plumbing
    pipewire
    wireplumber
    pipewire-pulseaudio
    pipewire-alsa
    NetworkManager-wifi
    bluez
    upower
    tuned-ppd
    # CLI, terminal, browser, fonts
    wl-clipboard
    pamixer
    playerctl
    fish
    ghostty
    fzf
    zoxide
    fontconfig
    google-noto-sans-fonts
    google-noto-emoji-fonts
    firefox
    curl
    unzip
    git
    chezmoi
)

sudo dnf install -y "${PACKAGES[@]}"

if ! command -v vicinae >/dev/null 2>&1; then
    curl -fsSL https://vicinae.com/install | bash
fi

# Install IoskeleyMono Nerd Font
FONT_DIR="$HOME/.local/share/fonts/IoskeleyMono"
if [ ! -d "$FONT_DIR" ]; then
    TMP_ZIP="$(mktemp --suffix=.zip)"
    curl -fsSL "https://github.com/ahatem/IoskeleyMono/releases/latest/download/IoskeleyMono-NerdFont.zip" -o "$TMP_ZIP"
    mkdir -p "$FONT_DIR"
    unzip -qo "$TMP_ZIP" -d "$FONT_DIR"
    rm -f "$TMP_ZIP"
    fc-cache -f "$FONT_DIR"
fi

# System services & graphical target (needed on minimal Fedora installs)
if ! systemctl is-enabled sddm.service >/dev/null 2>&1; then
    sudo systemctl enable sddm.service
fi
sudo systemctl enable bluetooth.service tuned.service tuned-ppd.service >/dev/null 2>&1 || true
sudo systemctl set-default graphical.target

# Ensure DMS fragments exist before first Mango login (DMS populates them on startup)
mkdir -p "$HOME/.config/mango/dms"
touch "$HOME/.config/mango/dms/"{colors,layout,cursor,input,outputs,windowrules}.conf

systemctl --user add-wants mango-session.target dms.service
if systemctl --user list-unit-files vicinae.service >/dev/null 2>&1; then
    systemctl --user add-wants graphical-session.target vicinae.service
fi

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" != "/usr/bin/fish" ]; then
    sudo chsh -s /usr/bin/fish "$USER"
fi
