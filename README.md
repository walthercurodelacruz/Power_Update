# 🚀 Power Update (v3.1) – Post-Instalación Modular para Linux

![Power Update Banner](https://img.shields.io/badge/Linux-Post--Install-blue?style=for-the-badge&logo=linux)
![Version](https://img.shields.io/badge/Versi%C3%B3n-3.1-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Estado-Activo-success?style=for-the-badge&color=green)
![License](https://img.shields.io/badge/Licencia-MIT-lightgrey?style=for-the-badge)

---

### ✨ ¿Qué es Power Update?

**Power Update** es una suite **modular, interactiva y automatizada** para configurar distribuciones Linux justo después de la instalación. Diseñado con una interfaz interactiva de consola guiada por menús y mouse, te permite seleccionar granularmente qué herramientas deseas instalar de forma cómoda y limpia.

---

### 🎯 Características principales (Novedades v3.1)

- 🖱️ **Navegación Interactiva con Mouse:** Interfaz gráfica en terminal gracias al protocolo SGR Mouse Tracking (`\e[?1000h\e[?1006h`), que permite marcar y desmarcar casillas haciendo clic directo y pulsar la botonera inferior.
- ⚡ **Interfaz Libre de Parpadeo (Flicker-Free):** Optimización del redibujado de consola para refrescar únicamente líneas modificadas mediante coordenadas absolutas, evitando parpadeos de terminal.
- 🧩 **Instalación Granular por Programa:** Selecciona individualmente cada utilidad en lugar de instalar categorías enteras por defecto.
- 🔄 **Actualización Obligatoria como Paso 1:** Los paquetes del sistema se actualizan de forma automática y obligatoria en segundo plano antes de proceder con el software seleccionado.
- 🛡️ **Robustecimiento de Seguridad:**
  - Descargas en directorios temporales seguros creados dinámicamente con `mktemp -d` (mitiga vulnerabilidades de enlaces simbólicos en `/tmp`).
  - Control riguroso de errores en pipelines mediante `set -o pipefail`.
  - Refresco en segundo plano del token de `sudo` para evitar expiración de credenciales a mitad del proceso.
- 🧪 **Suite de Pruebas Unitarias Integrada:** Test runner en Bash puro (`tests/run_tests.sh`) que valida el mapeo de paquetes, preferencia de comandos (ej. `dnf5` en Fedora) y códigos de salida sin tocar el sistema.
- 🚪 **Pausa al Finalizar:** El script aguarda la pulsación de una tecla para limpiar la pantalla, facilitando la visualización del resumen de instalación.

---

### 🧩 Módulos y Paquetes Disponibles

| Categoría          | Programas Incluidos                                                          |
|--------------------|------------------------------------------------------------------------------|
| `base_tools`       | `htop`, `btop`, `smartmontools`, `testdisk`, `inxi`, `timeshift`             |
| `net_support`      | `netcat`, `nethogs`, `iftop`, `whois`, `dig`, `arp-scan`                     |
| `security_tools`   | `nmap`, `hydra`, `john`, `gobuster`, `aircrack-ng`, `whatweb`, `hping3`, `cracklib-dicts`, `masscan`, `rockyou` |
| `fastfetch`        | Instalador de `fastfetch` + generación de configuración mínima compacta      |
| `multimedia`       | Codecs multimedia propietarios (`gstreamer`, `avcodec`) + reproductor `VLC`  |
| `dev_tools`        | `Node.js`, `npm`, `VS Code`, `DBeaver`                                       |
| `wine_unrar`       | Compatibilidad con Windows: `wine`, `winetricks`, `unrar`                    |

> *Nota: Se retiraron del proyecto el soporte para el tema Yaru, Shotcut y RustDesk.*

---

### ⚙️ Requisitos y Compatibilidad

El proyecto ha sido optimizado y restringido exclusivamente para entornos de producción en las siguientes distribuciones:
* **Debian** (Estable / Testing)
* **Ubuntu 26.04** en adelante
* **Fedora 43** en adelante (con soporte integrado para `dnf5`)

*Nota: Se ha eliminado el soporte para Arch Linux.*

---

### 🚀 Instalación rápida

1. Descarga el repositorio:
   ```bash
   git clone https://github.com/walthercurodelacruz/Power_Update.git
   cd Power_Update
   ```
2. Ejecuta el script principal:
   ```bash
   chmod +x power_update.sh
   ./power_update.sh
   ```
3. Para ejecutar la suite de pruebas unitarias:
   ```bash
   chmod +x tests/run_tests.sh
   ./tests/run_tests.sh
   ```

---

### 📝 Licencia

Este proyecto está licenciado bajo la **MIT License**.  
¡Libertad para usar, mejorar y compartir! 🙌

---

### 📛 Descargo de responsabilidad

> ⚠️ **Este proyecto incluye herramientas de ciberseguridad que pueden ser potencialmente invasivas si se usan fuera de un entorno autorizado.**
>
> Power Update ha sido diseñado con fines **educativos, de auditoría y diagnóstico** exclusivamente en **entornos controlados** o bajo **permiso explícito**.  
> **El autor no se responsabiliza por el uso indebido de estas herramientas.**
>
> 🛡️ **Utiliza siempre este software de forma ética y legal.**
