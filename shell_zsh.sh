# === shell_zsh.sh ===
# Instala ZSH, Oh My Zsh, plugins y configura shell avanzada

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$SCRIPT_DIR/Install-Logs"
LOG="$SCRIPT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_shell_zsh.log"
source "$SCRIPT_DIR/Global_functions.sh"

ZSH_PKGS=(lsd fzf mercurial zsh util-linux)
echo -e "${INFO} Instalando paquetes base para Zsh..." | tee -a "$LOG"
for pkg in "${ZSH_PKGS[@]}"; do
  install_package "$pkg" "$LOG"
done

if command -v zsh >/dev/null; then
  echo -e "${INFO} Instalando Oh My Zsh y plugins..." | tee -a "$LOG"

  [ ! -d "$HOME/.oh-my-zsh" ] && \
    sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended

  [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

  [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

  cp -b "$SCRIPT_DIR/assets/.zshrc" "$HOME/.zshrc"
  cp -b "$SCRIPT_DIR/assets/.zprofile" "$HOME/.zprofile"

  ZSH_PATH="$(which zsh)"
  if [[ "$SHELL" != *"zsh"* ]]; then
    if ! grep -q "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
    echo -e "${INFO} Shell por defecto cambiada a ZSH." | tee -a "$LOG"
  fi

  if command -v lsd >/dev/null && ! grep -q "alias ls='lsd" ~/.zshrc; then
    echo -e "\n# Alias para usar lsd como ls" >> ~/.zshrc
    echo "alias ls='lsd --group-dirs=first --icon=always --color=auto'" >> ~/.zshrc
    echo "alias ll='ls -l'" >> ~/.zshrc
    echo "alias la='ls -a'" >> ~/.zshrc
    echo "alias lla='ls -la'" >> ~/.zshrc
  fi

  [ -d "$HOME/.oh-my-zsh/themes" ] && [ -d "$SCRIPT_DIR/assets/add_zsh_theme" ] && \
    cp -r "$SCRIPT_DIR/assets/add_zsh_theme/"* "$HOME/.oh-my-zsh/themes"
fi

echo -e "${OK} ZSH y entorno configurados." | tee -a "$LOG"
