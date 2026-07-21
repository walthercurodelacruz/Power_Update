# === security_tools.sh ===
# Herramientas de ciberseguridad ofensiva y diagnóstico

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_security_tools.log"
source "$SCRIPT_DIR/Global_functions.sh"

echo -e "${INFO} Instalando herramientas de ciberseguridad..." | tee -a "$LOG"

TOOLS=(
  nmap
  hydra
  john
  gobuster
  aircrack-ng
  whatweb
  hping3
  cracklib-dicts
  masscan
)

for tool in "${TOOLS[@]}"; do
  install_package "$tool" "$LOG"
done

# === Wordlists multiplataforma ===
WORDLIST_DIR="$HOME/wordlists"
mkdir -p "$WORDLIST_DIR"

if [[ ! -f "$WORDLIST_DIR/rockyou.txt" ]]; then
  echo -e "${NOTE} Descargando wordlist rockyou.txt..." | tee -a "$LOG"
  curl -L https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt \
    -o "$WORDLIST_DIR/rockyou.txt" | tee -a "$LOG"

  if [[ -f "$WORDLIST_DIR/rockyou.txt" ]]; then
    echo -e "${OK} Wordlist rockyou.txt descargada correctamente." | tee -a "$LOG"
  else
    echo -e "${ERROR} No se pudo descargar rockyou.txt. Verifica conexión." | tee -a "$LOG"
  fi
else
  echo -e "${NOTE} rockyou.txt ya está presente en $WORDLIST_DIR. Se omite." | tee -a "$LOG"
fi

echo -e "${OK} Herramientas de seguridad instaladas correctamente." | tee -a "$LOG"

