# === base_tools.sh ===
# Herramientas de monitoreo, respaldo, diagnóstico y soporte remoto

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_base_tools.log"
source "$SCRIPT_DIR/Global_functions.sh"

echo -e "${INFO} Instalando herramientas base del sistema..." | tee -a "$LOG"

BASE_TOOLS=(
  htop
  btop
  smartmontools
  testdisk
  inxi
  timeshift
)

for tool in "${BASE_TOOLS[@]}"; do
  install_package "$tool" "$LOG"
done

# Joshuto tratado aparte para evitar ERROR innecesario
echo -e "${INFO} Instalando Joshuto..." | tee -a "$LOG"

if command -v joshuto &>/dev/null; then
  echo -e "${NOTE} Joshuto ya está instalado. Se omite." | tee -a "$LOG"
else
  echo -e "${NOTE} Intentando instalar joshuto desde gestor de paquetes..." | tee -a "$LOG"
  if (sudo dnf install -y joshuto 2>>"$LOG" || sudo apt install -y joshuto 2>>"$LOG" || sudo pacman -S --noconfirm joshuto 2>>"$LOG"); then
    echo -e "${OK} Joshuto instalado correctamente desde gestor de paquetes." | tee -a "$LOG"
  else
    echo -e "${NOTE} No se pudo instalar joshuto desde gestor. Se intentará desde código fuente..." | tee -a "$LOG"

    if ! command -v rustc &>/dev/null || ! command -v cargo &>/dev/null; then
      echo -e "${INFO} Rust no detectado. Instalando..." | tee -a "$LOG"
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y | tee -a "$LOG"
      source "$HOME/.cargo/env"
    fi

    cargo install joshuto | tee -a "$LOG"

    if command -v joshuto &>/dev/null; then
      echo -e "${OK} Joshuto instalado correctamente desde código fuente." | tee -a "$LOG"
    else
      echo -e "${ERROR} No se pudo instalar Joshuto. Verifica dependencias manualmente." | tee -a "$LOG"
    fi
  fi
fi

# Instalar RustDesk
echo -e "${INFO} Instalando RustDesk..." | tee -a "$LOG"
case "$DISTRO" in
  ubuntu|debian)
    LATEST_URL=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest \
      | grep browser_download_url | grep deb | grep amd64 | cut -d '"' -f 4 | head -n1)
    if [[ -n "$LATEST_URL" ]]; then
      wget -O /tmp/rustdesk.deb "$LATEST_URL" | tee -a "$LOG"
      sudo apt install -y /tmp/rustdesk.deb | tee -a "$LOG"
    else
      echo -e "${ERROR} No se pudo obtener la URL de RustDesk para Debian/Ubuntu." | tee -a "$LOG"
    fi
    ;;
  fedora)
    echo -e "${INFO} Instalando RustDesk desde Flatpak..." | tee -a "$LOG"
    if ! command -v flatpak &>/dev/null; then
      echo -e "${INFO} Flatpak no está instalado. Instalando..." | tee -a "$LOG"
      install_package flatpak "$LOG"
    fi
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo | tee -a "$LOG"
    flatpak install -y flathub com.rustdesk.RustDesk | tee -a "$LOG"
    ;;
  arch)
    if ! command -v yay &>/dev/null; then
      echo -e "${NOTE} Instalando yay para acceder a AUR..." | tee -a "$LOG"
      sudo pacman -S --needed git base-devel --noconfirm | tee -a "$LOG"
      git clone https://aur.archlinux.org/yay.git | tee -a "$LOG"
      cd yay && makepkg -si --noconfirm | tee -a "$LOG"
      cd .. && rm -rf yay
    fi
    yay -S rustdesk-bin --noconfirm | tee -a "$LOG"
    ;;
  *)
    echo -e "${ERROR} Distribución $DISTRO no soportada para RustDesk." | tee -a "$LOG"
    ;;
esac

echo -e "${OK} Herramientas base instaladas correctamente." | tee -a "$LOG"

