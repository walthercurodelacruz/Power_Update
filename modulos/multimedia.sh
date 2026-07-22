# === multimedia.sh ===
# Instalación de codecs multimedia, VLC y editor de video Shotcut

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_multimedia.log"
source "$SCRIPT_DIR/Global_functions.sh"

# 1. Codecs multimedia
if [[ " $SELECTED_MULTIMEDIA " =~ " codecs " ]]; then
  echo -e "${INFO} Instalando codecs multimedia..." | tee -a "$LOG"
  case "$DISTRO" in
    ubuntu)
      install_package ubuntu-restricted-extras "$LOG"
      install_package libavcodec-extra "$LOG"
      if ! dpkg -s libdvd-pkg &>/dev/null; then
          echo -e "${INFO} Preconfigurando libdvd-pkg..." | tee -a "$LOG"
          sudo debconf-set-selections <<EOF
libdvd-pkg libdvd-pkg/build boolean true
libdvd-pkg libdvd-pkg/upgrade note
libdvd-pkg libdvd-pkg/post-invoke_hook-remove boolean false
libdvd-pkg libdvd-pkg/post-invoke_hook-install boolean true
libdvd-pkg libdvd-pkg/first-install note
EOF
          sudo DEBIAN_FRONTEND=noninteractive apt install -y libdvd-pkg | tee -a "$LOG"
      else
          echo -e "${NOTE} Paquete ya instalado: libdvd-pkg. Se omite." | tee -a "$LOG"
      fi
      sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive libdvd-pkg | tee -a "$LOG"
      ;;

    debian)
      install_package libavcodec-extra "$LOG"
      if ! dpkg -s libdvd-pkg &>/dev/null; then
          echo -e "${INFO} Preconfigurando libdvd-pkg..." | tee -a "$LOG"
          sudo debconf-set-selections <<EOF
libdvd-pkg libdvd-pkg/build boolean true
libdvd-pkg libdvd-pkg/upgrade note
libdvd-pkg libdvd-pkg/post-invoke_hook-remove boolean false
libdvd-pkg libdvd-pkg/post-invoke_hook-install boolean true
libdvd-pkg libdvd-pkg/first-install note
EOF
          sudo DEBIAN_FRONTEND=noninteractive apt install -y libdvd-pkg | tee -a "$LOG"
      else
          echo -e "${NOTE} Paquete ya instalado: libdvd-pkg. Se omite." | tee -a "$LOG"
      fi
      sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive libdvd-pkg | tee -a "$LOG"
      ;;

    fedora)
      echo -e "${INFO} Habilitando RPM Fusion..." | tee -a "$LOG"
      sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm | tee -a "$LOG"

      install_package gstreamer1-plugins-base "$LOG"
      install_package gstreamer1-plugins-good "$LOG"
      install_package gstreamer1-plugins-bad-free "$LOG"
      install_package gstreamer1-plugins-ugly "$LOG"
      install_package gstreamer1-libav "$LOG"
      ;;



    *)
      echo -e "${ERROR} Distribución $DISTRO no soportada para codecs." | tee -a "$LOG"
      ;;
  esac
fi



# 3. VLC
if [[ " $SELECTED_MULTIMEDIA " =~ " vlc " ]]; then
  echo -e "${INFO} Instalando reproductor multimedia VLC..." | tee -a "$LOG"
  install_package vlc "$LOG"
fi

echo -e "${OK} Multimedia configurado correctamente." | tee -a "$LOG"

