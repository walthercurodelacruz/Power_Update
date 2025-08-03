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
  whatweb
)

for tool in "${SECURITY_TOOLS[@]}"; do
  install_package "$tool" "$LOG"
done

# Instalación alternativa de sqlmap si no se encuentra por paquete
if ! command -v sqlmap &>/dev/null; then
  echo -e "${NOTE} Instalando sqlmap desde pip..." | tee -a "$LOG"

  if ! command -v pip3 &>/dev/null; then
    echo -e "${INFO} pip3 no detectado. Instalando..." | tee -a "$LOG"
    install_package python3-pip "$LOG"
  fi

  pip3 install --upgrade sqlmap | tee -a "$LOG"

  if command -v sqlmap &>/dev/null; then
    echo -e "${OK} sqlmap instalado correctamente desde pip." | tee -a "$LOG"
  else
    echo -e "${ERROR} No se pudo instalar sqlmap. Verifica manualmente." | tee -a "$LOG"
  fi
else
  echo -e "${OK} sqlmap ya está instalado en el sistema." | tee -a "$LOG"
fi

echo -e "${OK} Herramientas de seguridad instaladas correctamente." | tee -a "$LOG"

