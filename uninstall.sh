#!/usr/bin/env bash
# ========================================
# tmux-ai-workspace Uninstaller
# ========================================
# Removes tmux-ai-workspace configuration
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${ORANGE}$1${NC}"
  echo -e "${ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# ========================================
# Main Uninstall
# ========================================

main() {
  print_header "tmux-ai-workspace Uninstaller"

  echo "This will remove tmux-ai-workspace configuration from your system."
  echo ""
  read -p "Continue? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
  fi
  echo ""

  # Remove from zsh
  if [[ -f ~/.zshrc ]]; then
    print_info "Checking ~/.zshrc..."
    if grep -q "tmux-ai-workspace" ~/.zshrc; then
      # Create backup
      local timestamp=$(date +%Y%m%d_%H%M%S)
      cp ~/.zshrc ~/.zshrc.backup_$timestamp
      print_success "Backed up to ~/.zshrc.backup_$timestamp"

      # Remove tmux-ai-workspace section
      sed -i.tmp '/# tmux-ai-workspace/,/alias tk=/d' ~/.zshrc
      rm -f ~/.zshrc.tmp

      # Also remove old ai() function if it exists without the marker
      if grep -q "^ai()" ~/.zshrc; then
        sed -i.tmp '/^ai()/,/^}/d' ~/.zshrc
        sed -i.tmp '/^alias ta=/d' ~/.zshrc
        sed -i.tmp '/^alias tl=/d' ~/.zshrc
        sed -i.tmp '/^alias tk=/d' ~/.zshrc
        rm -f ~/.zshrc.tmp
      fi

      print_success "Removed from ~/.zshrc"
    else
      print_info "Not found in ~/.zshrc"
    fi
  fi

  # Remove from bash
  if [[ -f ~/.bashrc ]]; then
    print_info "Checking ~/.bashrc..."
    if grep -q "tmux-ai-workspace" ~/.bashrc; then
      # Create backup
      local timestamp=$(date +%Y%m%d_%H%M%S)
      cp ~/.bashrc ~/.bashrc.backup_$timestamp
      print_success "Backed up to ~/.bashrc.backup_$timestamp"

      # Remove tmux-ai-workspace section
      sed -i.tmp '/# tmux-ai-workspace/,/alias tk=/d' ~/.bashrc
      rm -f ~/.bashrc.tmp

      # Also remove old ai() function if it exists without the marker
      if grep -q "^ai()" ~/.bashrc; then
        sed -i.tmp '/^ai()/,/^}/d' ~/.bashrc
        sed -i.tmp '/^alias ta=/d' ~/.bashrc
        sed -i.tmp '/^alias tl=/d' ~/.bashrc
        sed -i.tmp '/^alias tk=/d' ~/.bashrc
        rm -f ~/.bashrc.tmp
      fi

      print_success "Removed from ~/.bashrc"
    else
      print_info "Not found in ~/.bashrc"
    fi
  fi

  echo ""

  # Ask about tmux.conf
  if [[ -f ~/.tmux.conf ]]; then
    print_warning "Found ~/.tmux.conf"
    read -p "Remove ~/.tmux.conf? [y/N]: " remove_tmux
    if [[ "$remove_tmux" =~ ^[Yy]$ ]]; then
      local timestamp=$(date +%Y%m%d_%H%M%S)
      mv ~/.tmux.conf ~/.tmux.conf.backup_$timestamp
      print_success "Moved to ~/.tmux.conf.backup_$timestamp"
    else
      print_info "Keeping ~/.tmux.conf"
    fi
  fi

  echo ""

  # Ask about restoring from backup
  local latest_zsh_backup=$(ls -t ~/.zshrc.backup_* 2>/dev/null | head -n1)
  local latest_bash_backup=$(ls -t ~/.bashrc.backup_* 2>/dev/null | head -n1)
  local latest_tmux_backup=$(ls -t ~/.tmux.conf.backup_* 2>/dev/null | head -n1)

  if [[ -n "$latest_zsh_backup" ]] || [[ -n "$latest_bash_backup" ]] || [[ -n "$latest_tmux_backup" ]]; then
    print_info "Backup files found. Would you like to restore from the most recent backups?"
    read -p "Restore backups? [y/N]: " restore
    if [[ "$restore" =~ ^[Yy]$ ]]; then
      if [[ -n "$latest_zsh_backup" ]]; then
        cp "$latest_zsh_backup" ~/.zshrc
        print_success "Restored ~/.zshrc from $latest_zsh_backup"
      fi
      if [[ -n "$latest_bash_backup" ]]; then
        cp "$latest_bash_backup" ~/.bashrc
        print_success "Restored ~/.bashrc from $latest_bash_backup"
      fi
      if [[ -n "$latest_tmux_backup" ]]; then
        cp "$latest_tmux_backup" ~/.tmux.conf
        print_success "Restored ~/.tmux.conf from $latest_tmux_backup"
      fi
    fi
  fi

  echo ""

  # Ask about TPM
  if [[ -d ~/.tmux/plugins/tpm ]]; then
    print_warning "Found TPM installation at ~/.tmux/plugins/tpm"
    read -p "Remove TPM? [y/N]: " remove_tpm
    if [[ "$remove_tpm" =~ ^[Yy]$ ]]; then
      rm -rf ~/.tmux/plugins/tpm
      print_success "Removed TPM"
    else
      print_info "Keeping TPM"
    fi
  fi

  echo ""
  print_header "Uninstall Complete"

  echo "tmux-ai-workspace has been removed from your shell configuration."
  echo ""
  echo "To complete the removal, reload your shell:"
  if [[ -f ~/.zshrc ]]; then
    echo "  ${GREEN}source ~/.zshrc${NC}"
  fi
  if [[ -f ~/.bashrc ]]; then
    echo "  ${GREEN}source ~/.bashrc${NC}"
  fi
  echo ""
  echo "Backup files have been preserved and can be found with:"
  echo "  ${GREEN}ls -la ~/.*.backup_*${NC}"
  echo ""
}

main "$@"
