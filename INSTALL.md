# Fresh Fedora Minimal Laptop Install Guide

Step-by-step walkthrough from booting the Fedora Everything (netinstall) ISO to a working MangoWM + DMS desktop via chezmoi.

## 1. Boot the Fedora Everything ISO

1. Flash the Fedora Everything x86_64 ISO to a USB stick (Fedora Media Writer, `dd`, or Ventoy).
2. Boot the laptop from USB in **UEFI** mode. Fedora's kernel and bootloader are signed, so Secure Boot can stay enabled unless you plan to load unsigned kernel modules later.
3. Select **Install Fedora** from the GRUB menu.

## 2. Anaconda Graphical Installer

Complete the installer screens in this order. On a netinstall ISO, connecting to the network first unlocks software selection.

1. **Language and Keyboard**
   - Pick your system language and keyboard layout (e.g. English US).
2. **Network and Hostname (do this first)**
   - Connect to Ethernet or Wi-Fi and wait until it shows an IP address.
   - Set your hostname (e.g. `work-laptop`) and click Apply.
3. **Time and Date**
   - Set your timezone and confirm Network Time (NTP) is enabled.
4. **Installation Destination (Disk and Encryption)**
   - Select your internal NVMe/SSD.
   - Keep **Automatic** partitioning (Fedora uses Btrfs by default).
   - Check **Encrypt my data** (LUKS2) since this is a work laptop, and set a disk passphrase.
   - If the drive has an existing OS (Windows), choose to reclaim all space / delete existing partitions.
5. **Software Selection**
   - Under Base Environment (left column), select **Minimal Install**.
   - Under Additional software (right column), check **Hardware Support** (pulls in Wi-Fi, Bluetooth, and GPU firmware so you are not stranded offline on first boot).
   - Do not select any desktop environment (GNOME, KDE, etc.).
6. **Root Account and User Creation**
   - Leave the **Root account disabled/locked**.
   - Create your normal user and check **Make this user administrator** (`wheel` group for `sudo`). Do not skip this checkbox, or you will not have `sudo` on first boot.
7. **Begin Installation**
   - Review the summary, click **Begin Installation**, and wait for the base packages to download and install.
   - Click **Reboot** and unplug the USB stick.

## 3. First Boot (TTY)

Because you chose Minimal Install, the laptop boots into a plain text login prompt (`login:`). This is expected.

1. Unlock LUKS if prompted, then log in with your username and password.
2. Check network connectivity:
   ```bash
   ping -c 1 fedoraproject.org
   ```
3. If Wi-Fi did not carry over from the installer, connect with `nmcli`:
   ```bash
   nmcli device wifi list
   nmcli device wifi connect "<SSID>" --ask
   ```
   (If `nmcli device wifi list` shows no Wi-Fi device at all, plug in Ethernet or USB-tether your phone temporarily so `dnf` can pull the missing firmware.)

## 4. Bootstrap with chezmoi

1. Update the base system first (avoids kernel/Mesa/wlroots version mismatches) and install `git`, `gh`, and `chezmoi`:
   ```bash
   sudo dnf upgrade --refresh -y && sudo dnf install -y git gh chezmoi
   ```
2. **If `.chezmoi` is private**, authenticate GitHub from the TTY using the device flow (no browser needed on the laptop):
   ```bash
   gh auth login
   ```
   Choose **GitHub.com** -> **HTTPS** -> **Login with a web browser**. Approve the 8-character code on your phone at `https://github.com/login/device`. `gh` wires up `git`'s credential helper automatically.
   *(If `.chezmoi` is public, skip this step.)*
3. Pull and apply your dotfiles + Fedora setup script:
   ```bash
   chezmoi init --apply https://github.com/JoeriKaiser/.chezmoi.git
   ```
   This enables `duxlabs/dms` and `kaleedtc/mangowm`, installs MangoWM, DMS, Vicinae, Ghostty, IoskeleyMono Nerd Font, PipeWire, XWayland, Bluetooth, and power management, sets `fish` as your shell, and enables SDDM + `graphical.target`.
4. Reboot into the graphical login manager:
   ```bash
   sudo reboot
   ```

## 5. First Graphical Login (SDDM -> MangoWM)

1. At the SDDM login screen, check the session selector and make sure **Mango** is selected, then log in.
2. Open DMS Settings with `Ctrl+Shift+Alt+S` (or `Super+,`):
   - Set display scaling and monitor layout under **Displays** (DMS writes `~/.config/mango/dms/outputs.conf`).
   - Optionally select **IoskeleyMono** as your monospace font.
3. Verify your key shortcuts:
   - `Super+T` or `Super+Enter`: Ghostty
   - `Super+D`: Vicinae launcher
   - `Super+B` or `Meh+B`: toggle DMS top bar
   - `Super+Tab`: active-monitor window overview (`overcircle`)
   - `Super+Shift+Tab`: all-monitor thumbnail switcher (`switcher`)
   - `Super+R`: hot-reload MangoWM config

## Quick Troubleshooting

- **Rebooted to a TTY instead of SDDM:** run `systemctl get-default`. If it prints `multi-user.target`, run `sudo systemctl set-default graphical.target && sudo systemctl start sddm`.
- **DMS bar or notifications did not start:** run `systemctl --user status dms.service` and `dms doctor`.
- **Mango config error after editing:** run `mango -p` to see the exact line and keyword before reloading.
