#!/bin/bash
# === power_update.sh (modificado) ===
# Automatización modular post-instalación para Linux

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
source "$SCRIPT_DIR/Global_functions.sh"

clear
DATE=$(date "+%A, %d de %B de %Y")
TIME=$(date "+%H:%M:%S")
DISTRO=$(. /etc/os-release && echo "$NAME")
IP=$(hostname -I | awk '{print $1}')
HOST=$(hostname)
USER_SESSION=$USER

# === Bienvenida ===
echo -e "\n\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;36m                      🚀 POWER UPDATE – MODO AVANZADO\033[0m"
echo -e "\033[1;34m                Automatización modular para Linux post-instalación\033[0m"
echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33mSistema   :\033[0m  $DISTRO"
echo -e "\033[1;33mHostname  :\033[0m  $HOST"
echo -e "\033[1;33mUsuario   :\033[0m  $USER_SESSION"
echo -e "\033[1;33mFecha     :\033[0m  $DATE"
echo -e "\033[1;33mHora      :\033[0m  $TIME"
echo -e "\033[1;33mIP Local  :\033[0m  $IP"
echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
sleep 2

# Detectar distribución
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo -e "${ERROR} No se pudo detectar el sistema operativo."
    exit 1
fi

# Verificar dependencias base
REQUIRED_DEPS=(curl unzip git)
for dep in "${REQUIRED_DEPS[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        echo -e "${NOTE} Instalando dependencia: $dep"
        install_package "$dep" "$SCRIPT_DIR/Install-Logs/install-dependencies.log"
    fi
done

HAS_GUI=true
[ -z "$DISPLAY" ] && HAS_GUI=false

# Módulos por categoría
declare -A MODULES=(
  [system_update]="Actualización del sistema"
  [base_tools]="Herramientas base del sistema"
  [net_support]="Soporte técnico de red"
  [security_tools]="Herramientas de ciberseguridad"
  [fastfetch]="Información del sistema"
  [shell_zsh]="Shell avanzada con Zsh"
  [multimedia]="Codecs multimedia y editores"
  [dev_tools]="Herramientas de desarrollo"
  [wine_unrar]="Compatibilidad y compresión"
)

declare -A MODULE_APPS=(
  [system_update]="→ Actualiza todos los paquetes del sistema"
  [base_tools]="→ htop, btop, smartmontools, testdisk, inxi, timeshift"
  [net_support]="→ netcat, nethogs, iftop, whois, dig, arp-scan"
  [security_tools]="→ nmap, masscan, hping3, hydra, gobuster, wireshark, tcpdump, ettercap, proxychains-ng, macchanger, aircrack-ng"
  [fastfetch]="→ fastfetch"
  [shell_zsh]="→ zsh, Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, lsd, fzf"
  [multimedia]="→ Codecs multimedia, gstreamer, Shotcut"
  [dev_tools]="→ nodejs, npm, Visual Studio Code"
  [wine_unrar]="→ wine, winetricks, unrar"
)

# Menú interactivo
echo -e "\n\033[1;36m[?] Explora y elige los módulos a instalar\033[0m"
echo -e "\033[1;35m──────────────────────────────────────────────────────────\033[0m"
SELECTION=()
for mod in "${!MODULES[@]}"; do
    while true; do
        echo -e "\n\033[1;34m→ ${mod}:\033[0m ${MODULES[$mod]}"
        echo -e "   \033[1;33mIncluye:\033[0m ${MODULE_APPS[$mod]}"
        echo -ne "\033[1;36m¿Deseas instalar este módulo? [s/n]: \033[0m"
        read -r respuesta
        case "$respuesta" in
            [sS]) SELECTION+=("$mod"); break ;;
            [nN]) break ;;
            *) echo -e "\033[1;33m[!] Entrada no válida. Escribe 's' o 'n'.\033[0m" ;;
        esac
    done
done

echo -e "\n\033[1;36mResumen de selección:\033[0m"
for mod in "${SELECTION[@]}"; do
    echo -e "  ✔ ${mod} → ${MODULES[$mod]}"
done

echo -ne "\n\033[1;36m¿Deseas continuar con la instalación? [s/n]: \033[0m"
read -r continuar
[[ "$continuar" =~ ^[sS]$ ]] || { echo -e "\n${NOTE} Instalación cancelada."; exit 0; }

# Ejecutar módulos
MODULES_DONE=()
for module in "${SELECTION[@]}"; do
    if [ "$module" == "gtk_themes" ] || [ "$module" == "multimedia" ]; then
        [ "$HAS_GUI" = true ] && source "$SCRIPT_DIR/$module.sh" && MODULES_DONE+=("$module") || echo -e "${NOTE} Sin GUI, se omite $module."
    else
        source "$SCRIPT_DIR/$module.sh"
        MODULES_DONE+=("$module")
    fi
    sleep 1
done

# Resumen final
echo -e "\n\033[1;32m[MÓDULOS EJECUTADOS]\033[0m"
for mod in "${MODULES_DONE[@]}"; do
    echo -e "- $mod: ${MODULES[$mod]}"
done

echo -e "\n${OK} Post-instalación completada."
