#!/usr/bin/env bash
set -euo pipefail

if ! grep -qi '^id=fedora' /etc/os-release; then
    echo "Skipping Fedora package setup (not running on Fedora)."
    exit 0
fi

if [ ! -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:duxlabs:dms.repo ]; then
    sudo dnf copr enable -y duxlabs/dms
fi

PACKAGES=(
    niri
    dms
    sddm
    xwayland-satellite
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    gnome-keyring
    wl-clipboard
    pamixer
    playerctl
    fuzzel
    swaylock
    fish
    ghostty
    fzf
    zoxide
    google-noto-sans-fonts
    google-noto-emoji-fonts
    firefox
    curl
    git
    chezmoi
)

sudo dnf install -y "${PACKAGES[@]}"

if ! systemctl is-enabled sddm.service >/dev/null 2>&1; then
    sudo systemctl enable sddm.service
fi

systemctl --user add-wants niri.service dms.service

CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" != "/usr/bin/fish" ]; then
    sudo chsh -s /usr/bin/fish "$USER"
fi
