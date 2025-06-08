# === security_tools.sh ===
# Herramientas de hacking ético y ciberseguridad

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_security_tools.log"
source "$SCRIPT_DIR/Global_functions.sh"

echo -e "${INFO} Instalando herramientas de ciberseguridad..." | tee -a "$LOG"

SECURITY_TOOLS=(
  nmap
  masscan
  hping3
  hydra
  gobuster
  wireshark
  tcpdump
  ettercap
  proxychains-ng
  macchanger
  aircrack-ng
)

for tool in "${SECURITY_TOOLS[@]}"; do
  install_package "$tool" "$LOG"
done

echo -e "${OK} Herramientas de seguridad instaladas correctamente." | tee -a "$LOG"
