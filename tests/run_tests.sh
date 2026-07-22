#!/bin/bash
# === tests/run_tests.sh ===
# Suite de pruebas unitarias para Power Update (sin dependencias externas)

set -o pipefail

# Colores para reporte
PASS_COLOR="\033[1;32m"
FAIL_COLOR="\033[1;31m"
TITLE_COLOR="\033[1;35m"
RESET="\033[0m"

# Variables globales para el contador de pruebas
PASSED_TESTS=0
FAILED_TESTS=0

# === Mocking framework ===
# Sobrescribir builtin 'command' para simular disponibilidad de gestores
command() {
    if [[ "$1" == "-v" ]]; then
        if [[ "$2" == "apt" || "$2" == "apt-get" ]]; then
            [[ "$MOCK_PM" == "apt" ]] && return 0
            return 1
        elif [[ "$2" == "dnf5" ]]; then
            [[ "$MOCK_PM" == "dnf5" ]] && return 0
            return 1
        elif [[ "$2" == "dnf" ]]; then
            [[ "$MOCK_PM" == "dnf" || "$MOCK_PM" == "dnf5" ]] && return 0
            return 1
        fi
    fi
    builtin command "$@"
}

# Simular estado de instalación de paquetes rpm
rpm() {
    if [[ "$1" == "-q" ]]; then
        local pkg="$2"
        for p in "${INSTALLED_PACKAGES[@]}"; do
            [[ "$p" == "$pkg" ]] && return 0
        done
        return 1
    fi
    return 0
}

# Simular estado de instalación de paquetes deb
dpkg() {
    if [[ "$1" == "-s" ]]; then
        local pkg="$2"
        for p in "${INSTALLED_PACKAGES[@]}"; do
            [[ "$p" == "$pkg" ]] && return 0
        done
        return 1
    fi
    return 0
}

# Simular sudo para interceptar comandos de instalación y simular fallos
sudo() {
    # Guardar la llamada sin 'DEBIAN_FRONTEND=noninteractive' para simplificar aserción
    local cleaned_args=()
    for arg in "$@"; do
        [[ "$arg" == "DEBIAN_FRONTEND=noninteractive" ]] && continue
        cleaned_args+=("$arg")
    done
    SUDO_CALLS+=("${cleaned_args[*]}")
    return "$MOCK_SUDO_STATUS"
}
export -f sudo

# === Aserciones ===
assert_equals() {
    local expected="$1"
    local actual="$2"
    local msg="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo -e "  ${PASS_COLOR}[PASS]${RESET} $msg"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${FAIL_COLOR}[FAIL]${RESET} $msg"
        echo "         Esperado: '$expected'"
        echo "         Obtenido: '$actual'"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

assert_true() {
    local actual="$1"
    local msg="$2"
    if [ "$actual" = true ] || [ "$actual" -eq 0 ] 2>/dev/null; then
        echo -e "  ${PASS_COLOR}[PASS]${RESET} $msg"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${FAIL_COLOR}[FAIL]${RESET} $msg"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# === Cargar Código a Probar ===
# Cargamos Global_functions.sh. Dado que tiene 'set -o pipefail', correrá seguro.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
source "$SCRIPT_DIR/Global_functions.sh"

# === Casos de Prueba ===

test_package_mapping_ubuntu() {
    DISTRO="ubuntu"
    MOCK_PM="apt"
    INSTALLED_PACKAGES=()
    SUDO_CALLS=()
    MOCK_SUDO_STATUS=0
    
    # Probar mapeo de cracklib-dicts
    install_package "cracklib-dicts" "" >/dev/null
    assert_equals "apt install -y cracklib-runtime" "${SUDO_CALLS[0]}" "Ubuntu: cracklib-dicts mapea a cracklib-runtime"
    
    # Probar mapeo de dig
    SUDO_CALLS=()
    install_package "dig" "" >/dev/null
    assert_equals "apt install -y bind9-dnsutils" "${SUDO_CALLS[0]}" "Ubuntu: dig mapea a bind9-dnsutils"

    # Probar mapeo de netcat
    SUDO_CALLS=()
    install_package "netcat" "" >/dev/null
    assert_equals "apt install -y netcat-openbsd" "${SUDO_CALLS[0]}" "Ubuntu: netcat mapea a netcat-openbsd"
}

test_package_mapping_fedora() {
    DISTRO="fedora"
    MOCK_PM="dnf"
    INSTALLED_PACKAGES=()
    SUDO_CALLS=()
    MOCK_SUDO_STATUS=0
    
    # Probar mapeo de cracklib-dicts
    install_package "cracklib-dicts" "" >/dev/null
    assert_equals "dnf install -y cracklib-dicts" "${SUDO_CALLS[0]}" "Fedora: cracklib-dicts mapea a cracklib-dicts"
    
    # Probar mapeo de dig
    SUDO_CALLS=()
    install_package "dig" "" >/dev/null
    assert_equals "dnf install -y bind-utils" "${SUDO_CALLS[0]}" "Fedora: dig mapea a bind-utils"

    # Probar mapeo de netcat
    SUDO_CALLS=()
    install_package "netcat" "" >/dev/null
    assert_equals "dnf install -y nc" "${SUDO_CALLS[0]}" "Fedora: netcat mapea a nc"
}

test_dnf5_preference_on_fedora() {
    DISTRO="fedora"
    MOCK_PM="dnf5"
    INSTALLED_PACKAGES=()
    SUDO_CALLS=()
    MOCK_SUDO_STATUS=0
    
    install_package "htop" "" >/dev/null
    assert_equals "dnf5 install -y htop" "${SUDO_CALLS[0]}" "Fedora prefiere dnf5 si está disponible"
}

test_package_already_installed() {
    DISTRO="ubuntu"
    MOCK_PM="apt"
    INSTALLED_PACKAGES=("htop")
    SUDO_CALLS=()
    MOCK_SUDO_STATUS=0
    
    install_package "htop" "" >/dev/null
    local res=$?
    
    assert_equals 0 "$res" "Retorna éxito (0) si el paquete ya está instalado"
    assert_equals 0 "${#SUDO_CALLS[@]}" "No ejecuta comandos de instalación si el paquete ya está instalado"
}

test_installation_failure() {
    DISTRO="ubuntu"
    MOCK_PM="apt"
    INSTALLED_PACKAGES=()
    SUDO_CALLS=()
    MOCK_SUDO_STATUS=1 # Simular fallo
    
    install_package "htop" "" >/dev/null
    local res=$?
    
    assert_equals 1 "$res" "Retorna error (1) si la instalación falla"
}

# === Ejecución de la Suite ===
echo -e "\n${TITLE_COLOR}═══════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${TITLE_COLOR}             🧪 CORRIENDO PRUEBAS UNITARIAS DE POWER UPDATE${RESET}"
echo -e "${TITLE_COLOR}═══════════════════════════════════════════════════════════════════════${RESET}"

echo -e "\n[Grupo: Mapeo de Paquetes en Ubuntu]"
test_package_mapping_ubuntu

echo -e "\n[Grupo: Mapeo de Paquetes en Fedora]"
test_package_mapping_fedora

echo -e "\n[Grupo: Preferencia DNF5]"
test_dnf5_preference_on_fedora

echo -e "\n[Grupo: Evitar Re-instalación]"
test_package_already_installed

echo -e "\n[Grupo: Códigos de Error]"
test_installation_failure

echo -e "\n${TITLE_COLOR}═══════════════════════════════════════════════════════════════════════${RESET}"
echo -e "  Pruebas superadas : ${PASS_COLOR}${PASSED_TESTS}${RESET}"
echo -e "  Pruebas fallidas  : ${FAIL_COLOR}${FAILED_TESTS}${RESET}"
echo -e "${TITLE_COLOR}═══════════════════════════════════════════════════════════════════════${RESET}\n"

if [ "$FAILED_TESTS" -eq 0 ]; then
    exit 0
else
    exit 1
fi
