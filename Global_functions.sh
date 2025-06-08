#!/bin/bash

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
    if command -v dnf &>/dev/null; then
        if rpm -q "$pkg" &>/dev/null; then
            echo -e "${NOTE} Paquete ya instalado: $pkg. Se omite."
            return 0
        fi
        sudo dnf install -y "$pkg"
    elif command -v apt &>/dev/null; then
        if dpkg -s "$pkg" &>/dev/null; then
            echo -e "${NOTE} Paquete ya instalado: $pkg. Se omite."
            return 0
        fi
        sudo apt install -y "$pkg"
    elif command -v pacman &>/dev/null; then
        if pacman -Q "$pkg" &>/dev/null; then
            echo -e "${NOTE} Paquete ya instalado: $pkg. Se omite."
            return 0
        fi
        sudo pacman -S --noconfirm "$pkg"
    else
        echo -e "${ERROR} Gestor de paquetes no compatible."
        return 1
    fi
    if [[ $? -eq 0 ]]; then
        echo -e "${OK} Instalado correctamente: $pkg"
    else
        echo -e "${ERROR} Falló la instalación de: $pkg"
    fi
}
