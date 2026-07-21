# === dev_tools.sh ===
# Herramientas de desarrollo: Node.js, npm, Visual Studio Code y DBeaver

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_dev_tools.log"
source "$SCRIPT_DIR/Global_functions.sh"

echo -e "${INFO} Instalando Node.js y npm..." | tee -a "$LOG"
install_package nodejs "$LOG"
install_package npm "$LOG"

echo -e "${INFO} Instalando Visual Studio Code..." | tee -a "$LOG"
case "$DISTRO" in
  ubuntu|debian)
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
    rm packages.microsoft.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update | tee -a "$LOG"
    install_package code "$LOG"
    ;;
  fedora)
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf check-update | tee -a "$LOG"
    install_package code "$LOG"
    ;;
  arch)
    if ! command -v yay &>/dev/null; then
      echo -e "${NOTE} Instalando yay para acceder a AUR..." | tee -a "$LOG"
      sudo pacman -S --needed git base-devel --noconfirm | tee -a "$LOG"
      git clone https://aur.archlinux.org/yay.git | tee -a "$LOG"
      cd yay && makepkg -si --noconfirm | tee -a "$LOG"
      cd .. && rm -rf yay
    fi
    yay -S visual-studio-code-bin --noconfirm | tee -a "$LOG"
    ;;
  *)
    echo -e "${ERROR} Distribución $DISTRO no soportada para VSCode." | tee -a "$LOG"
    ;;
esac

echo -e "${INFO} Instalando DBeaver..." | tee -a "$LOG"
case "$DISTRO" in
  ubuntu|debian)
    wget -O /tmp/dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb | tee -a "$LOG"
    sudo apt install -y /tmp/dbeaver.deb | tee -a "$LOG"
    ;;
  fedora)
    wget -O /tmp/dbeaver.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm | tee -a "$LOG"
    sudo dnf install -y /tmp/dbeaver.rpm | tee -a "$LOG"
    ;;
  arch)
    yay -S dbeaver --noconfirm | tee -a "$LOG"
    ;;
  *)
    echo -e "${ERROR} Distribución $DISTRO no soportada para DBeaver." | tee -a "$LOG"
    ;;
esac

echo -e "${OK} Herramientas de desarrollo instaladas correctamente." | tee -a "$LOG"

