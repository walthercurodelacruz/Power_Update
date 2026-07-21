# === net_support.sh ===
# Herramientas de soporte técnico y diagnóstico de red

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_net_support.log"
source "$SCRIPT_DIR/Global_functions.sh"

echo -e "${INFO} Instalando herramientas de soporte de red..." | tee -a "$LOG"

NET_TOOLS=(
  netcat
  nethogs
  iftop
  whois
  dig
  arp-scan
)

for tool in "${NET_TOOLS[@]}"; do
  install_package "$tool" "$LOG"
done

echo -e "${OK} Herramientas de red instaladas correctamente." | tee -a "$LOG"
