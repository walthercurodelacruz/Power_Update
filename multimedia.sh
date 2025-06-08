# === multimedia.sh ===
# Instalación de codecs multimedia y editor de video Shotcut (sin ffmpeg)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_multimedia.log"
source "$SCRIPT_DIR/Global_functions.sh"

echo -e "${INFO} Instalando codecs multimedia..." | tee -a "$LOG"

case "$DISTRO" in
  ubuntu|debian)
    install_package ubuntu-restricted-extras "$LOG"
    install_package libavcodec-extra "$LOG"
    install_package libdvd-pkg "$LOG"
    sudo dpkg-reconfigure libdvd-pkg | tee -a "$LOG"
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

  arch)
    install_package gst-plugins-base "$LOG"
    install_package gst-plugins-good "$LOG"
    install_package gst-plugins-bad "$LOG"
    install_package gst-plugins-ugly "$LOG"
    ;;

  *)
    echo -e "${ERROR} Distribución $DISTRO no soportada." | tee -a "$LOG"
    ;;
esac

echo -e "${INFO} Instalando editor de video Shotcut..." | tee -a "$LOG"
case "$DISTRO" in
  ubuntu|debian)
    sudo add-apt-repository ppa:haraldhv/shotcut -y | tee -a "$LOG"
    sudo apt update | tee -a "$LOG"
    install_package shotcut "$LOG"
    ;;
  fedora|arch)
    install_package shotcut "$LOG"
    ;;
  *)
    echo -e "${ERROR} Distribución $DISTRO no soportada para Shotcut." | tee -a "$LOG"
    ;;
esac

echo -e "${OK} Multimedia configurado correctamente." | tee -a "$LOG"

