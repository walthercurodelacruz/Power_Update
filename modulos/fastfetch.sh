# === fastfetch.sh ===
# Instala y configura fastfetch con un layout compacto básico

set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_fastfetch.log"
source "$SCRIPT_DIR/Global_functions.sh"

if [[ " $SELECTED_FASTFETCH " =~ " fastfetch " ]]; then
    install_package "fastfetch" "$LOG"
fi

if [[ " $SELECTED_FASTFETCH " =~ " config " ]]; then
    CONFIG_PATH="$HOME/.config/fastfetch/config-compact.jsonc"
    if [ ! -f "$CONFIG_PATH" ]; then
        echo -e "${INFO} Creando configuración mínima para fastfetch..." | tee -a "$LOG"
        mkdir -p "$(dirname "$CONFIG_PATH")"
        cat <<EOF > "$CONFIG_PATH"
{
  "modules": [
    "title",
    "os",
    "kernel",
    "shell",
    "terminal"
  ]
}
EOF
    else
        echo -e "${NOTE} Configuración ya existe. No se sobrescribirá." | tee -a "$LOG"
    fi
fi

echo -e "${OK} Fastfetch configurado correctamente." | tee -a "$LOG"
