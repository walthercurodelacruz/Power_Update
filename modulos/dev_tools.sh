# === dev_tools.sh ===
# Herramientas de desarrollo: Node.js, npm, Visual Studio Code y DBeaver

set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_dev_tools.log"
source "$SCRIPT_DIR/Global_functions.sh"

if [[ " $SELECTED_DEV_TOOLS " =~ " nodejs " ]]; then
  echo -e "${INFO} Instalando Node.js..." | tee -a "$LOG"
  install_package nodejs "$LOG"
fi

if [[ " $SELECTED_DEV_TOOLS " =~ " npm " ]]; then
  echo -e "${INFO} Instalando npm..." | tee -a "$LOG"
  install_package npm "$LOG"
fi

if [[ " $SELECTED_DEV_TOOLS " =~ " vscode " ]]; then
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
    *)
      echo -e "${ERROR} Distribución $DISTRO no soportada para VSCode." | tee -a "$LOG"
      ;;
  esac
fi

if [[ " $SELECTED_DEV_TOOLS " =~ " dbeaver " ]]; then
  echo -e "${INFO} Instalando DBeaver..." | tee -a "$LOG"
  
  # Crear un directorio temporal seguro con permisos restringidos
  TMP_DIR=$(mktemp -d -t dbeaver_install_XXXXXX)
  chmod 700 "$TMP_DIR"
  trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

  case "$DISTRO" in
    ubuntu|debian)
      wget -O "$TMP_DIR/dbeaver.deb" https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb | tee -a "$LOG"
      sudo apt install -y "$TMP_DIR/dbeaver.deb" | tee -a "$LOG"
      ;;
    fedora)
      wget -O "$TMP_DIR/dbeaver.rpm" https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm | tee -a "$LOG"
      sudo dnf install -y "$TMP_DIR/dbeaver.rpm" | tee -a "$LOG"
      ;;
    *)
      echo -e "${ERROR} Distribución $DISTRO no soportada para DBeaver." | tee -a "$LOG"
      ;;
  esac
fi

echo -e "${OK} Herramientas de desarrollo instaladas correctamente." | tee -a "$LOG"

