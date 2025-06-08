# === gtk_themes.sh ===
# Descarga y aplica temas GTK + iconos desde repositorio externo

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_gtk_themes.log"
source "$SCRIPT_DIR/Global_functions.sh"

install_package unzip "$LOG"

[ -d "GTK-themes-icons" ] && rm -rf GTK-themes-icons

echo -e "${INFO} Clonando temas GTK desde GitHub..." | tee -a "$LOG"
if git clone --depth 1 https://github.com/JaKooLit/GTK-themes-icons.git ; then
    cd GTK-themes-icons
    chmod +x auto-extract.sh
    ./auto-extract.sh
    cd ..
    echo -e "${OK} Temas extraídos en ~/.icons y ~/.themes" | tee -a "$LOG"
else
    echo -e "${ERROR} Falló la descarga de temas GTK." | tee -a "$LOG"
fi
