# Fedora Niri + DMS Dotfiles

Dotfiles and Fedora bootstrap scripts managed with [chezmoi](https://www.chezmoi.io/) for a minimal Fedora setup running **niri**, **duxlabs/dms**, **fish** (+ `fisher` plugins), and **ghostty**.

## Bootstrap on a fresh minimal Fedora install

```bash
sudo dnf install -y git chezmoi
chezmoi init --apply <your-repo-url>
```

Then log out / reboot so `sddm` and `fish` as your default login shell take effect.

## Day-to-day usage

- Edit a config through chezmoi: `chezmoi edit ~/.config/niri/config.kdl`
- Add/remove Fish plugins: `chezmoi edit ~/.config/fish/fish_plugins && chezmoi apply` (`fisher update` runs automatically when `fish_plugins` changes)
- Auto-generated DMS files (`~/.config/niri/dms/*.kdl`, `~/.config/ghostty/themes/dankcolors`, `~/.config/gtk-*/dank-colors.css`) are intentionally unmanaged by chezmoi.
