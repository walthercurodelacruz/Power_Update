#!/bin/bash
set -o pipefail

# === Colores ===
OK="\033[1;32m[OK]\033[0m"
INFO="\033[1;34m[INFO]\033[0m"
NOTE="\033[1;33m[NOTE]\033[0m"
ERROR="\033[1;31m[ERROR]\033[0m"
SKY_BLUE="\033[1;36m"
RESET="\033[0m"

# === Función para instalar paquetes con detección de gestor ===
install_package() {
    local pkg="$1"
    local log_file="$2"
    
    if [ -z "$DISTRO" ]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        fi
    fi
    
    # Mapeo de nombres de paquetes por distribución
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        case "$pkg" in
            dig) pkg="bind9-dnsutils" ;;
            netcat) pkg="netcat-openbsd" ;;
            cracklib-dicts) pkg="cracklib-runtime" ;;
        esac
    elif [[ "$DISTRO" == "fedora" ]]; then
        case "$pkg" in
            dig) pkg="bind-utils" ;;
            netcat) pkg="nc" ;;
            cracklib-dicts) pkg="cracklib-dicts" ;;
        esac

    fi

    local status=0

    if command -v dnf5 &>/dev/null || command -v dnf &>/dev/null; then
        if rpm -q "$pkg" &>/dev/null; then
            echo -e "${NOTE} Paquete ya instalado: $pkg. Se omite."
            return 0
        fi
        local pm="dnf"
        command -v dnf5 &>/dev/null && pm="dnf5"
        if [ -n "$log_file" ]; then
            sudo $pm install -y "$pkg" 2>&1 | tee -a "$log_file"
            status=${PIPESTATUS[0]}
        else
            sudo $pm install -y "$pkg"
            status=$?
        fi
    elif command -v apt &>/dev/null; then
        if dpkg -s "$pkg" &>/dev/null; then
            echo -e "${NOTE} Paquete ya instalado: $pkg. Se omite."
            return 0
        fi
        if [ -n "$log_file" ]; then
            sudo DEBIAN_FRONTEND=noninteractive apt install -y "$pkg" 2>&1 | tee -a "$log_file"
            status=${PIPESTATUS[0]}
        else
            sudo DEBIAN_FRONTEND=noninteractive apt install -y "$pkg"
            status=$?
        fi

    else
        echo -e "${ERROR} Gestor de paquetes no compatible."
        return 1
    fi

    if [[ $status -eq 0 ]]; then
        if [ -n "$log_file" ]; then
            echo -e "${OK} Instalado correctamente: $pkg" | tee -a "$log_file"
        else
            echo -e "${OK} Instalado correctamente: $pkg"
        fi
        return 0
    else

        if [ -n "$log_file" ]; then
            echo -e "${ERROR} Falló la instalación de: $pkg" | tee -a "$log_file"
        else
            echo -e "${ERROR} Falló la instalación de: $pkg"
        fi
        return 1
    fi
}
