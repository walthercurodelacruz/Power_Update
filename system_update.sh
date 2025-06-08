# === system_update.sh ===
# Actualiza completamente el sistema según la distribución detectada

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/update-$(date +%d-%H%M%S).log"
source "$SCRIPT_DIR/Global_functions.sh"

case "$DISTRO" in
    fedora)
        echo -e "${INFO} Actualizando sistema con DNF..." | tee -a "$LOG"
        sudo dnf update -y && sudo dnf upgrade -y && sudo dnf distro-sync -y && sudo dnf autoremove -y | tee -a "$LOG"
        ;;
    ubuntu|debian)
        echo -e "${INFO} Actualizando sistema con APT..." | tee -a "$LOG"
        sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y | tee -a "$LOG"
        ;;
    arch)
        echo -e "${INFO} Actualizando sistema con Pacman..." | tee -a "$LOG"
        sudo pacman -Syu --noconfirm | tee -a "$LOG"
        ;;
    *)
        echo -e "${ERROR} Distribución $DISTRO no soportada para actualización automática." | tee -a "$LOG"
        exit 1
        ;;
esac

echo -e "${OK} Actualización del sistema completada." | tee -a "$LOG"
