# === base_tools.sh ===
# Herramientas de monitoreo, respaldo, diagnóstico y soporte remoto

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
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
  if [[ " $SELECTED_BASE_TOOLS " =~ " $tool " ]]; then
    install_package "$tool" "$LOG"
  fi
done



echo -e "${OK} Herramientas base instaladas correctamente." | tee -a "$LOG"

