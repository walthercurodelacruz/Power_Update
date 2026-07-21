# === fastfetch.sh ===
# Instala y configura fastfetch con un layout compacto básico

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_fastfetch.log"
source "$SCRIPT_DIR/Global_functions.sh"

install_package "fastfetch" "$LOG"

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

echo -e "${OK} Fastfetch configurado correctamente." | tee -a "$LOG"
