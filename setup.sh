#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  Fedora KDE Configuration — Automated Setup
#  Forked from ilyamiro/nixos-configuration
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/hurteam-ops/fedora-kde-configuration/main/setup.sh | bash
#    Or: chmod +x setup.sh && ./setup.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Banner ──
echo -e "${CYAN}"
echo "████████████████████████████████████████████████████████████████████████████"
echo "█                                                                          █"
echo "█              Fedora KDE Configuration — Setup Script                     █"
echo "█         Forked from ilyamiro/nixos-configuration                         █"
echo "████████████████████████████████████████████████████████████████████████████"
echo -e "${NC}"

# ── Safety checks ──
if [[ "$EUID" -eq 0 ]]; then
    echo -e "${RED}ERROR: Do NOT run this script as root! It will use sudo where needed.${NC}"
    exit 1
fi

if [[ ! -f /etc/fedora-release ]]; then
    echo -e "${YELLOW}WARNING: This does not appear to be Fedora Linux. Proceed with caution.${NC}"
fi

# Determine script directory (supports curl | bash and local execution)
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "bash" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || true)"
fi

if [[ -z "$SCRIPT_DIR" || ! -d "$SCRIPT_DIR" ]]; then
    # Running via curl pipe — try to clone
    SCRIPT_DIR="$HOME/fedora-kde-configuration"
    if [[ ! -d "$SCRIPT_DIR" ]]; then
        echo -e "${CYAN}Cloning fedora-kde-configuration...${NC}"
        git clone https://github.com/hurteam-ops/fedora-kde-configuration.git "$SCRIPT_DIR"
    fi
fi

cd "$SCRIPT_DIR"

# ── 1. Enable RPM Fusion ──
echo -e "${GREEN}[1/9] Enabling RPM Fusion repositories...${NC}"
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# ── 2. DNF Configuration ──
echo -e "${GREEN}[2/9] Optimizing DNF configuration...${NC}"
sudo cp config/system/dnf.conf /etc/dnf/dnf.conf 2>/dev/null || true
# Ensure max_parallel_downloads is set
if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
fi
sudo dnf upgrade --refresh -y

# ── 3. Install Packages ──
echo -e "${GREEN}[3/9] Installing packages...${NC}"
# Remove comments and blank lines, then install
PACKAGES=$(grep -v '^\s*#' config/system/packages.list | grep -v '^\s*$' | tr '\n' ' ')
sudo dnf install -y --skip-unavailable --allowerasing $PACKAGES

# ── 4. Install development packages (group) ──
echo -e "${GREEN}[4/9] Installing development tools...${NC}"
sudo dnf groupinstall -y "Development Tools" "Development Libraries" || true

# ── 4b. Install matugen (if available in COPR, skip if not) ──
if ! command -v matugen &>/dev/null; then
    echo -e "${CYAN}Installing matugen from COPR...${NC}"
    sudo dnf copr enable -y inox/matugen 2>/dev/null && sudo dnf install -y matugen || echo -e "${YELLOW}matugen not available. Install manually later.${NC}"
fi

# ── 5. Flatpak apps (not in Fedora repos) ──
echo -e "${GREEN}[5/10] Installing Flatpak apps...${NC}"
if command -v flatpak &>/dev/null; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    flatpak install -y flathub md.obsidian.Obsidian 2>/dev/null || echo -e "${YELLOW}Obsidian not installed (flathub may need setup)${NC}"
    flatpak install -y flathub org.onlyoffice.desktopeditors 2>/dev/null || echo -e "${YELLOW}OnlyOffice not installed${NC}"
    flatpak install -y flathub com.obsproject.Studio 2>/dev/null || echo -e "${YELLOW}OBS Studio flatpak not installed${NC}"
else
    echo -e "${YELLOW}flatpak not available. Install manually: sudo dnf install flatpak${NC}"
fi

# ── 6. Kernel Network Tuning ──
echo -e "${GREEN}[5/9] Applying kernel network tuning...${NC}"
sudo mkdir -p /etc/sysctl.d
sudo cp config/system/sysctl.d/99-network.conf /etc/sysctl.d/99-network.conf
sudo sysctl -p /etc/sysctl.d/99-network.conf 2>/dev/null || true

# ── 6. Dotfiles Setup ──
echo -e "${GREEN}[7/10] Installing dotfiles...${NC}"

# Ensure config directories exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/fonts"

# Kitty
mkdir -p "$HOME/.config/kitty"
cp config/programs/kitty/kitty.conf "$HOME/.config/kitty/kitty.conf"

# ZSH
mkdir -p "$HOME/.config/zsh"
cp config/programs/zsh/.zshrc "$HOME/.zshrc"
cp config/programs/zsh/zsh-init.sh "$HOME/.config/zsh/zsh-init.sh"

# Neovim
mkdir -p "$HOME/.config/nvim"
cp -r config/programs/neovim/nvim/* "$HOME/.config/nvim/"

# Rofi
mkdir -p "$HOME/.config/rofi"
cp config/programs/rofi/config.rasi "$HOME/.config/rofi/config.rasi"
# Copy theme if it exists (from original)
if [[ -f config/programs/rofi/theme.rasi ]]; then
    cp config/programs/rofi/theme.rasi "$HOME/.config/rofi/theme.rasi"
fi

# Cava
mkdir -p "$HOME/.config/cava"
cp config/programs/cava/config "$HOME/.config/cava/config"

# Matugen
mkdir -p "$HOME/.config/matugen"
cp config/programs/matugen/config.toml "$HOME/.config/matugen/config.toml"
if [[ -d config/programs/matugen/templates ]]; then
    mkdir -p "$HOME/.config/matugen/templates"
    cp -r config/programs/matugen/templates/* "$HOME/.config/matugen/templates/"
fi

# Fonts
if [[ -d config/programs/JetBrainsMono ]]; then
    cp -r config/programs/JetBrainsMono "$HOME/.local/share/fonts/"
fi
if [[ -f config/programs/iosevka-nerd-font.ttf ]]; then
    cp config/programs/iosevka-nerd-font.ttf "$HOME/.local/share/fonts/"
fi
fc-cache -f

# ── 7. KDE Plasma Configuration ──
echo -e "${GREEN}[8/10] Configuring KDE Plasma...${NC}"

mkdir -p "$HOME/.config"

# KWin rules
mkdir -p "$HOME/.config/kwin"
if [[ -f config/plasma/kwin/kwinrulesrc ]]; then
    cp config/plasma/kwin/kwinrulesrc "$HOME/.config/kwinrulesrc"
fi

# Konsole
if [[ -f config/plasma/konsolerc ]]; then
    cp config/plasma/konsolerc "$HOME/.config/konsolerc"
fi
if [[ -f config/plasma/konsoleshellprofile.profile ]]; then
    mkdir -p "$HOME/.local/share/konsole"
    cp config/plasma/konsoleshellprofile.profile "$HOME/.local/share/konsole/Shell.profile"
fi

# Keyboard & input
if [[ -f config/plasma/kcminputrc ]]; then
    cp config/plasma/kcminputrc "$HOME/.config/kcminputrc"
fi

# Shortcuts
if [[ -f config/plasma/kglobalshortcutsrc ]]; then
    cp config/plasma/kglobalshortcutsrc "$HOME/.config/kglobalshortcutsrc"
fi

# Apply plasma configs via kstart5 if available
if command -v kstart5 &>/dev/null; then
    echo -e "${CYAN}KDE session detected. Applying Plasma settings...${NC}"
    # Apply KDE global settings
    kwriteconfig5 --file kcminputrc --group Keyboard --key RepeatRate 55 2>/dev/null || true
    kwriteconfig5 --file kcminputrc --group Keyboard --key RepeatDelay 250 2>/dev/null || true
    echo -e "${GREEN}KDE settings applied for current session.${NC}"
else
    echo -e "${YELLOW}Not in a KDE session. Configs will apply on next login.${NC}"
fi

# ── 9. ZSH as default shell ──
echo -e "${GREEN}[9/10] Setting ZSH as default shell...${NC}"
if command -v zsh &>/dev/null; then
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        chsh -s "$(which zsh)" 2>/dev/null || echo -e "${YELLOW}Could not change shell. Run: chsh -s $(which zsh)${NC}"
    fi

    # Install Oh-My-Zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${CYAN}Installing Oh-My-Zsh...${NC}"
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true
    fi
fi

# ── 10. Finalize ──
echo -e "${GREEN}[10/10] Cleanup and final steps...${NC}"

# Update font cache again
fc-cache -f

# Create a shortcut to the configuration
if [[ ! -L "$HOME/fedora-kde-configuration" ]]; then
    ln -sf "$SCRIPT_DIR" "$HOME/fedora-kde-configuration" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup complete! Fedora KDE Configuration installed.${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "  1. ${YELLOW}Reboot${NC} or log out and select KDE Plasma"
echo -e "  2. Set your wallpaper: ${CYAN}System Settings → Appearance → Wallpaper${NC}"
echo -e "  3. Generate dynamic theme: ${CYAN}matugen image ~/wallpaper.jpg${NC}"
echo -e "  4. Run ${CYAN}fetch${NC} to show system info"
echo -e "  5. Run ${CYAN}qcopy${NC} to copy files to clipboard"
echo ""
echo -e "  Config location: ${CYAN}$SCRIPT_DIR${NC}"
echo -e "  Dotfiles: ${CYAN}$HOME/.config/{kitty,nvim,rofi,cava,matugen,zsh}${NC}"
echo ""
