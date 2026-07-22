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

if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" && "$DISTRO" != "fedora" ]]; then
    echo -e "${ERROR} Distribución '$DISTRO' no soportada. Este script solo es compatible con Debian, Ubuntu (26.04+) y Fedora (43+)."
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

# Move cursor to row R, col C: \e[R;CH
move_to() {
    printf "\e[%d;%dH" "$1" "$2"
}

# Limpieza segura para restaurar el estado del terminal
cleanup() {
    printf '\e[?1000l\e[?1006l' # Desactivar rastreo de mouse
    printf '\e[?25h'             # Mostrar cursor de texto
    clear
}

read_input() {
    local char
    # Leer un carácter con tiempo de espera de 0.1s
    if read -s -n 1 -t 0.1 char; then
        if [[ "$char" == $'\e' ]]; then
            read -s -n 2 -t 0.1 rest
            if [[ "$rest" == "[<" ]]; then
                local seq=""
                while read -s -n 1 -t 0.1 c; do
                    seq="${seq}${c}"
                    if [[ "$c" == "M" || "$c" == "m" ]]; then
                        break
                    fi
                done
                if [[ "$seq" =~ ^([0-9]+)\;([0-9]+)\;([0-9]+)([Mm])$ ]]; then
                    CLICK_BTN="${BASH_REMATCH[1]}"
                    CLICK_X="${BASH_REMATCH[2]}"
                    CLICK_Y="${BASH_REMATCH[3]}"
                    CLICK_EVENT="${BASH_REMATCH[4]}"
                    return 2 # Evento de mouse
                fi
            fi
            return 1 # Otro escape
        else
            KEY_PRESSED="$char"
            return 0 # Teclado
        fi
    fi
    return 3 # Sin entrada
}

# Definición de categorías
CATEGORIES=(
  "base_tools"
  "net_support"
  "security_tools"
  "fastfetch"
  "multimedia"
  "dev_tools"
  "wine_unrar"
)

declare -A CATEGORY_NAMES=(
  [base_tools]="Herramientas Base del Sistema"
  [net_support]="Soporte Técnico de Red"
  [security_tools]="Herramientas de Ciberseguridad"
  [fastfetch]="Información del Sistema"
  [multimedia]="Codecs Multimedia y Editores"
  [dev_tools]="Herramientas de Desarrollo"
  [wine_unrar]="Compatibilidad y Compresión"
)

declare -A CATEGORY_PROGS=(
  [base_tools]="htop btop smartmontools testdisk inxi timeshift"
  [net_support]="netcat nethogs iftop whois dig arp-scan"
  [security_tools]="nmap hydra john gobuster aircrack-ng whatweb hping3 cracklib-dicts masscan rockyou"
  [fastfetch]="fastfetch config"
  [multimedia]="codecs vlc"
  [dev_tools]="nodejs npm vscode dbeaver"
  [wine_unrar]="wine unrar"
)

declare -A PROG_NAMES=(
  [htop]="htop (Monitoreo de procesos interactivo)"
  [btop]="btop (Monitor de sistema moderno en terminal)"
  [smartmontools]="smartmontools (Control y monitoreo de discos)"
  [testdisk]="testdisk (Recuperación de datos de disco)"
  [inxi]="inxi (Información detallada del hardware)"
  [timeshift]="timeshift (Instantáneas y restauración del sistema)"
  [netcat]="netcat (Lectura y escritura en conexiones de red)"
  [nethogs]="nethogs (Monitoreo de tráfico de red por proceso)"
  [iftop]="iftop (Monitoreo de ancho de banda por interfaz)"
  [whois]="whois (Información de registro de dominios)"
  [dig]="dig (Consultas y diagnósticos DNS)"
  [arp-scan]="arp-scan (Escáner de red local ARP)"
  [nmap]="nmap (Escáner de seguridad y puertos de red)"
  [hydra]="hydra (Crackeador de contraseñas de red rápido)"
  [john]="john (John the Ripper - descifrador de hashes)"
  [gobuster]="gobuster (Búsqueda de directorios y DNS por fuerza bruta)"
  [aircrack-ng]="aircrack-ng (Auditoría de redes inalámbricas)"
  [whatweb]="whatweb (Identificación de tecnologías web)"
  [hping3]="hping3 (Generador y analizador de paquetes TCP/IP)"
  [cracklib-dicts]="cracklib-dicts (Diccionarios de contraseñas para cracklib)"
  [masscan]="masscan (Escáner de puertos de alta velocidad)"
  [rockyou]="Descargar wordlist rockyou.txt (~14 millones de contraseñas)"
  [fastfetch]="fastfetch (Información visual del sistema)"
  [config]="Crear configuración minimalista y compacta de Fastfetch"
  [codecs]="Codecs multimedia (gstreamer, avcodec)"
  [vlc]="VLC (Reproductor multimedia universal)"
  [nodejs]="Node.js (Entorno de ejecución JavaScript)"
  [npm]="npm (Gestor de paquetes para Node.js)"
  [vscode]="Visual Studio Code (Editor de código avanzado)"
  [dbeaver]="DBeaver CE (Administrador de bases de datos relacionales)"
  [wine]="Wine & Winetricks (Compatibilidad con software de Windows)"
  [unrar]="unrar (Soporte para extracción de archivos .rar)"
)

# Inicializar estado de selección
declare -A SELECTION_STATUS
for cat in "${CATEGORIES[@]}"; do
    for prog in ${CATEGORY_PROGS[$cat]}; do
        SELECTION_STATUS[$prog]=true
    done
done

draw_menu_absolute() {
    local cat_idx="$1"
    local cat_key="${CATEGORIES[$cat_idx]}"
    local cat_name="${CATEGORY_NAMES[$cat_key]}"
    local progs=(${CATEGORY_PROGS[$cat_key]})
    
    clear
    move_to 2 1
    echo -e "\033[1;35m  ═══════════════════════════════════════════════════════════════════════\033[0m"
    move_to 3 1
    echo -e "\033[1;36m             🚀 POWER UPDATE – SELECCIÓN DE PROGRAMAS\033[0m"
    move_to 4 1
    echo -e "\033[1;34m                Categoría $((cat_idx+1)) de ${#CATEGORIES[@]}: $cat_name\033[0m"
    move_to 5 1
    echo -e "\033[1;35m  ═══════════════════════════════════════════════════════════════════════\033[0m"
    move_to 7 5
    echo -e "\033[1;33mHaz click con el mouse sobre cada programa para marcar/desmarcar:\033[0m"
    
    local row=9
    local num=1
    for prog in "${progs[@]}"; do
        local check="[ ]"
        if [ "${SELECTION_STATUS[$prog]}" = true ]; then
            check="\033[1;32m[✔]\033[0m"
        else
            check="\033[1;30m[ ]\033[0m"
        fi
        move_to $row 8
        echo -e "$check  \033[1;33m$num)\033[0m \033[1;37m${PROG_NAMES[$prog]}\033[0m"
        row=$((row + 1))
        num=$((num + 1))
    done
    
    # Botonera fija en la fila 21
    move_to 20 1
    echo -e "\033[1;35m  ───────────────────────────────────────────────────────────────────────\033[0m"
    move_to 21 1
    if [ $cat_idx -eq 0 ]; then
        echo -e "     \033[1;30m[ < Atrás ]\033[0m            \033[1;32m[ Siguiente > ]\033[0m            \033[1;31m[ Cancelar ]\033[0m"
    else
        echo -e "     \033[1;34m[ < Atrás ]\033[0m            \033[1;32m[ Siguiente > ]\033[0m            \033[1;31m[ Cancelar ]\033[0m"
    fi
    move_to 22 1
    echo -e "\033[1;35m  ───────────────────────────────────────────────────────────────────────\033[0m"
    move_to 24 1
}

redraw_option() {
    local cat_idx="$1"
    local cat_key="${CATEGORIES[$cat_idx]}"
    local progs=(${CATEGORY_PROGS[$cat_key]})
    local idx="$2"
    local prog="${progs[$idx]}"
    local row=$((9 + idx))
    local num=$((idx + 1))
    
    local check="[ ]"
    if [ "${SELECTION_STATUS[$prog]}" = true ]; then
        check="\033[1;32m[✔]\033[0m"
    else
        check="\033[1;30m[ ]\033[0m"
    fi
    move_to $row 8
    printf "$check  \033[1;33m$num)\033[0m \033[1;37m${PROG_NAMES[$prog]}\033[0m\e[K"
    move_to 24 1
}

trap cleanup EXIT INT TERM

# Activar modo mouse y ocultar cursor
printf '\e[?1000h\e[?1006h'
printf '\e[?25l'

# Navegación del asistente
current_cat=0
last_cat=-1
while [ $current_cat -lt ${#CATEGORIES[@]} ]; do
    if [ $current_cat -ne $last_cat ]; then
        draw_menu_absolute "$current_cat"
        last_cat=$current_cat
    fi
    
    cat_key="${CATEGORIES[$current_cat]}"
    progs=(${CATEGORY_PROGS[$cat_key]})
    num_progs=${#progs[@]}
    
    # Leer entrada
    read_input
    code=$?
    
    if [ $code -eq 2 ]; then # Evento de mouse
        if [ "$CLICK_EVENT" = "M" ]; then
            if [ $CLICK_Y -ge 9 ] && [ $CLICK_Y -lt $((9 + num_progs)) ]; then
                idx=$((CLICK_Y - 9))
                prog="${progs[$idx]}"
                if [ "${SELECTION_STATUS[$prog]}" = true ]; then
                    SELECTION_STATUS[$prog]=false
                else
                    SELECTION_STATUS[$prog]=true
                fi
                redraw_option "$current_cat" "$idx"
            elif [ $CLICK_Y -eq 21 ]; then
                if [ $CLICK_X -ge 5 ] && [ $CLICK_X -le 17 ]; then
                    if [ $current_cat -gt 0 ]; then
                        current_cat=$((current_cat - 1))
                    fi
                elif [ $CLICK_X -ge 28 ] && [ $CLICK_X -le 46 ]; then
                    current_cat=$((current_cat + 1))
                elif [ $CLICK_X -ge 58 ] && [ $CLICK_X -le 73 ]; then
                    echo -e "\n${NOTE} Instalación cancelada."
                    cleanup
                    exit 0
                fi
            fi
        fi
    elif [ $code -eq 0 ]; then # Teclado
        if [[ "$KEY_PRESSED" =~ ^[1-9]$ ]]; then
            idx=$((KEY_PRESSED - 1))
            if [ $idx -lt $num_progs ]; then
                prog="${progs[$idx]}"
                if [ "${SELECTION_STATUS[$prog]}" = true ]; then
                    SELECTION_STATUS[$prog]=false
                else
                    SELECTION_STATUS[$prog]=true
                fi
                redraw_option "$current_cat" "$idx"
            fi
        elif [[ "$KEY_PRESSED" == "s" || "$KEY_PRESSED" == "S" || "$KEY_PRESSED" == $'\n' ]]; then
            current_cat=$((current_cat + 1))
        elif [[ "$KEY_PRESSED" == "a" || "$KEY_PRESSED" == "A" ]]; then
            if [ $current_cat -gt 0 ]; then
                current_cat=$((current_cat - 1))
            fi
        elif [[ "$KEY_PRESSED" == "q" || "$KEY_PRESSED" == "Q" ]]; then
            echo -e "\n${NOTE} Instalación cancelada."
            cleanup
            exit 0
        fi
    fi
done

# Restaurar estado del terminal para la ejecución
cleanup

# Compilar listado final
SELECTION=()
for cat in "${CATEGORIES[@]}"; do
    for prog in ${CATEGORY_PROGS[$cat]}; do
        if [ "${SELECTION_STATUS[$prog]}" = true ]; then
            SELECTION+=("$prog")
        fi
    done
done

if [ ${#SELECTION[@]} -eq 0 ]; then
    echo -e "\n${NOTE} No seleccionaste ningún programa. Saliendo."
    exit 0
fi

# Resumen de confirmación antes de instalar
clear
echo -e "\n\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;36m                     📋 RESUMEN DE INSTALACIÓN\033[0m"
echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -e "Los siguientes programas seleccionados serán instalados:\n"
for prog in "${SELECTION[@]}"; do
    echo -e "  \033[1;32m✔\033[0m \033[1;37m${PROG_NAMES[$prog]}\033[0m"
done
echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -ne "\n¿Deseas proceder con la instalación? [s/n]: "
read -r continuar
[[ "$continuar" =~ ^[sS]$ ]] || { echo -e "\n${NOTE} Instalación cancelada."; exit 0; }

# Exportar las selecciones individuales filtradas por categoría para los subshells
for cat in "${CATEGORIES[@]}"; do
    selected_progs=""
    for prog in ${CATEGORY_PROGS[$cat]}; do
        if [ "${SELECTION_STATUS[$prog]}" = true ]; then
            selected_progs="${selected_progs} ${prog}"
        fi
    done
    env_var_name="SELECTED_$(echo "$cat" | tr '[:lower:]' '[:upper:]')"
    export "$env_var_name"="$selected_progs"
done

# Exportar variables críticas para que los subshells las hereden
export DISTRO
export HAS_GUI

# Paso 1 automático: Actualización del Sistema
echo -e "\n\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;36m⚙️  Paso 1: Ejecutando Actualización del Sistema...\033[0m"
echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
bash "$SCRIPT_DIR/modulos/system_update.sh"
sleep 1

# Ejecutar módulos de manera aislada en subshells
MODULES_DONE=()
for cat in "${CATEGORIES[@]}"; do
    env_var_name="SELECTED_$(echo "$cat" | tr '[:lower:]' '[:upper:]')"
    if [ -n "${!env_var_name}" ]; then
        echo -e "\n\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
        echo -e "\033[1;36m⚙️  Ejecutando: ${CATEGORY_NAMES[$cat]}...\033[0m"
        echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
        
        if [ "$cat" == "gtk_themes" ] || [ "$cat" == "multimedia" ]; then
            if [ "$HAS_GUI" = true ]; then
                bash "$SCRIPT_DIR/modulos/$cat.sh"
                if [ $? -eq 0 ]; then
                    MODULES_DONE+=("$cat")
                fi
            else
                echo -e "${NOTE} Sin GUI, se omite ${CATEGORY_NAMES[$cat]}."
            fi
        else
            bash "$SCRIPT_DIR/modulos/$cat.sh"
            if [ $? -eq 0 ]; then
                MODULES_DONE+=("$cat")
            fi
        fi
        sleep 1
    fi
done

# Resumen final
clear
echo -e "\n\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;32m                     🏁 POST-INSTALACIÓN COMPLETADA\033[0m"
echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\n\033[1;36mCategorías ejecutadas con éxito:\033[0m"
if [ ${#MODULES_DONE[@]} -eq 0 ]; then
    echo -e "  Ninguna categoría fue procesada."
else
    for cat in "${MODULES_DONE[@]}"; do
        echo -e "  \033[1;32m✔\033[0m ${CATEGORY_NAMES[$cat]}"
    done
fi
echo -e "\033[1;35m═══════════════════════════════════════════════════════════════════════\033[0m"

echo -ne "\n\033[1;36mPresiona [Enter] para finalizar y limpiar la pantalla... \033[0m"
read -r
