# === wine_unrar.sh ===
# Soporte para archivos .rar y compatibilidad con software Windows

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_wine_unrar.log"
source "$SCRIPT_DIR/Global_functions.sh"

if [[ " $SELECTED_WINE_UNRAR " =~ " unrar " ]]; then
  echo -e "${INFO} Instalando soporte para archivos .rar..." | tee -a "$LOG"
  install_package unrar "$LOG"
fi

if [[ " $SELECTED_WINE_UNRAR " =~ " wine " ]]; then
  echo -e "${INFO} Instalando Wine y Winetricks..." | tee -a "$LOG"
  case "$DISTRO" in
    ubuntu|debian)
      sudo dpkg --add-architecture i386
      echo -e "${INFO} Actualizando lista de paquetes para arquitectura i386..." | tee -a "$LOG"
      sudo apt update | tee -a "$LOG"
      install_package wine64 "$LOG"
      install_package wine32 "$LOG"
      install_package winetricks "$LOG"
      ;;
    fedora)
      install_package wine "$LOG"
      install_package winetricks "$LOG"
      ;;
    *)
      echo -e "${ERROR} Distribución $DISTRO no soportada para Wine." | tee -a "$LOG"
      ;;
  esac
fi

echo -e "${OK} Compatibilidad y soporte de archivos configurado." | tee -a "$LOG"
