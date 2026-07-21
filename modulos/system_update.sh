# === system_update.sh ===
# Actualiza completamente el sistema según la distribución detectada
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/update-$(date +%d-%H%M%S).log"
source "$SCRIPT_DIR/Global_functions.sh"

case "$DISTRO" in
    fedora)
        echo -e "${INFO} Actualizando sistema con DNF..." | tee -a "$LOG"
        sudo dnf update -y && sudo dnf upgrade -y && sudo dnf distro-sync -y && sudo dnf autoremove -y | tee -a "$LOG"

        echo -e "${INFO} Verificando si el tema de Ubuntu (Yaru) está instalado..." | tee -a "$LOG"
        if [ ! -d "/usr/share/themes/Yaru" ]; then
            echo -e "${NOTE} Tema Yaru no detectado. Procediendo con la instalación manual desde GitHub..." | tee -a "$LOG"

            install_package git "$LOG"
            install_package meson "$LOG"
            install_package sassc "$LOG"
            install_package libglibutil-devel "$LOG"
            install_package gtk3-devel "$LOG"
            install_package gnome-themes-extra "$LOG"
            install_package gnome-shell-devel "$LOG"
            install_package ninja-build "$LOG"
            install_package libgnomekbd-devel "$LOG"

            cd /tmp || exit
            git clone https://github.com/ubuntu/yaru.git | tee -a "$LOG"
            cd yaru || exit
            meson setup build | tee -a "$LOG"
            ninja -C build | tee -a "$LOG"
            sudo ninja -C build install | tee -a "$LOG"

            echo -e "${OK} Tema Yaru instalado correctamente desde código fuente." | tee -a "$LOG"
        else
            echo -e "${OK} El tema Yaru ya está instalado." | tee -a "$LOG"
        fi
        ;;

    ubuntu|debian)
        echo -e "${INFO} Actualizando sistema con APT..." | tee -a "$LOG"
        sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y | tee -a "$LOG"

        echo -e "${INFO} Verificando si el tema de Ubuntu (yaru) está instalado..." | tee -a "$LOG"
        if ! dpkg -s yaru-theme-gtk &>/dev/null || ! dpkg -s yaru-theme-icon &>/dev/null; then
            echo -e "${NOTE} Tema yaru no detectado. Procediendo con la instalación..." | tee -a "$LOG"
            install_package yaru-theme-gtk "$LOG"
            install_package yaru-theme-icon "$LOG"
        else
            echo -e "${OK} El tema yaru ya está instalado." | tee -a "$LOG"
        fi
        ;;

    arch)
        echo -e "${INFO} Actualizando sistema con Pacman..." | tee -a "$LOG"
        sudo pacman -Syu --noconfirm | tee -a "$LOG"
        echo -e "${NOTE} En Arch no se instalará el tema de Ubuntu." | tee -a "$LOG"
        ;;

    *)
        echo -e "${ERROR} Distribución $DISTRO no soportada para actualización automática." | tee -a "$LOG"
        exit 1
        ;;
esac

echo -e "${OK} Actualización del sistema completada." | tee -a "$LOG"

