#!/usr/bin/env bash
# ========================================
# tmux-ai-workspace Installer
# ========================================
# Interactive installer for AI-optimized tmux workspace
set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSET_ROOT="$SCRIPT_DIR"
BASE_URL="${TMUX_AI_WORKSPACE_BASE_URL:-https://raw.githubusercontent.com/LorcanChinnock/tmux-ai-workspace/main}"
TMP_ASSET_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t tmux-ai-workspace-assets)"

cleanup_tmp_assets() {
  rm -rf "$TMP_ASSET_DIR"
}

trap cleanup_tmp_assets EXIT

download_asset() {
  local rel_path=$1
  local target="$TMP_ASSET_DIR/$rel_path"
  local target_dir
  target_dir="$(dirname "$target")"
  mkdir -p "$target_dir"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$BASE_URL/$rel_path" -o "$target" || return 1
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$target" "$BASE_URL/$rel_path" || return 1
  else
    return 1
  fi

  [[ -f "$target" ]]
}

resolve_asset_path() {
  local rel_path=$1
  local local_path="$ASSET_ROOT/$rel_path"

  if [[ -f "$local_path" ]]; then
    echo "$local_path"
    return 0
  fi

  if download_asset "$rel_path"; then
    echo "$TMP_ASSET_DIR/$rel_path"
    return 0
  fi

  return 1
}

# Source platform detection utilities
if [[ -f "$PWD/scripts/detect-platform.sh" ]]; then
  ASSET_ROOT="$PWD"
fi

DETECT_PLATFORM_PATH="$(resolve_asset_path scripts/detect-platform.sh || true)"
if [[ -z "$DETECT_PLATFORM_PATH" ]]; then
  echo "Error: scripts/detect-platform.sh not found."
  echo "If you ran via curl, try cloning and running ./install.sh from the repo."
  echo "Or set TMUX_AI_WORKSPACE_BASE_URL to a raw GitHub URL for your fork."
  exit 1
fi

source "$DETECT_PLATFORM_PATH"

# Configuration variables (set by interactive Q&A)
CLAUDE_MODE="dangerous"
INSTALL_LAZYGIT="yes"
THEME="default"
INSTALL_TPM="yes"
SHELL_TYPE="auto"

# Color codes for output (TTY only)
if [[ -t 1 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[1;33m'
  BLUE=$'\033[0;34m'
  ORANGE=$'\033[0;33m'
  NC=$'\033[0m' # No Color
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  ORANGE=""
  NC=""
fi

# ========================================
# Helper Functions
# ========================================

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

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# ========================================
# Interactive Q&A
# ========================================

ask_questions() {
  print_header "🚀 tmux-ai-workspace installer"

  echo "This installer will set up an AI-optimized tmux workspace with:"
  echo "  • Mouse-enabled tmux with vim keybindings"
  echo "  • 3-pane layout (Claude CLI, Terminal, Git)"
  echo "  • Shell integration with ai() command"
  echo ""
  echo "Let's customize your installation..."
  echo ""

  # Question 1: Claude CLI mode
  echo -e "${BLUE}Question 1/5: Claude CLI mode${NC}"
  echo "How should Claude CLI run in your workspace?"
  echo "  1) Dangerous mode (skip permissions, faster) [default]"
  echo "  2) Safe mode (prompt for permissions)"
  echo "  3) Custom flags"
  read -p "Choice [1-3]: " claude_choice

  case $claude_choice in
    2) CLAUDE_MODE="safe" ;;
    3)
      echo ""
      read -p "Enter custom Claude CLI flags: " custom_flags
      CLAUDE_MODE="$custom_flags"
      ;;
    *) CLAUDE_MODE="dangerous" ;;
  esac
  print_success "Claude mode: $CLAUDE_MODE"
  echo ""

  # Question 2: lazygit
  echo -e "${BLUE}Question 2/5: Git UI${NC}"
  echo "Install lazygit for the Git pane?"
  echo "  Y) Yes, install lazygit [default]"
  echo "  N) No, skip lazygit"
  read -p "Choice [Y/n]: " lazygit_choice

  case $lazygit_choice in
    [Nn]*) INSTALL_LAZYGIT="no" ;;
    *) INSTALL_LAZYGIT="yes" ;;
  esac
  print_success "Lazygit: $INSTALL_LAZYGIT"
  echo ""

  # Question 3: Color theme
  echo -e "${BLUE}Question 3/5: Color theme${NC}"
  echo "Choose your tmux color theme:"
  echo "  1) Default (orange/grey) [default]"
  echo "  2) Blue"
  echo "  3) Green"
  echo "  4) Monochrome"
  read -p "Choice [1-4]: " theme_choice

  case $theme_choice in
    2) THEME="blue" ;;
    3) THEME="green" ;;
    4) THEME="monochrome" ;;
    *) THEME="default" ;;
  esac
  print_success "Theme: $THEME"
  echo ""

  # Question 4: TPM plugins
  echo -e "${BLUE}Question 4/5: Tmux Plugin Manager${NC}"
  echo "Install TPM (Tmux Plugin Manager) and plugins?"
  echo "  1) Yes, full set (tmux-sensible, tmux-yank, tmux-resurrect) [default]"
  echo "  2) Minimal (just TPM)"
  echo "  3) No, skip TPM"
  read -p "Choice [1-3]: " tpm_choice

  case $tpm_choice in
    2) INSTALL_TPM="minimal" ;;
    3) INSTALL_TPM="no" ;;
    *) INSTALL_TPM="yes" ;;
  esac
  print_success "TPM: $INSTALL_TPM"
  echo ""

  # Question 5: Shell
  echo -e "${BLUE}Question 5/5: Shell configuration${NC}"
  echo "Which shell should be configured?"
  echo "  1) Auto-detect [default]"
  echo "  2) zsh only"
  echo "  3) bash only"
  echo "  4) Both zsh and bash"
  read -p "Choice [1-4]: " shell_choice

  case $shell_choice in
    2) SHELL_TYPE="zsh" ;;
    3) SHELL_TYPE="bash" ;;
    4) SHELL_TYPE="both" ;;
    *) SHELL_TYPE="auto" ;;
  esac
  print_success "Shell: $SHELL_TYPE"
  echo ""
}

# ========================================
# Platform Detection
# ========================================

check_platform() {
  print_header "Platform Detection"

  PLATFORM=$(detect_platform)
  print_info "Detected platform: $PLATFORM"

  if ! check_package_manager; then
    print_error "Package manager check failed"
    exit 1
  fi

  echo ""
}

# ========================================
# Dependency Installation
# ========================================

install_dependencies() {
  print_header "Installing Dependencies"

  # Check and install tmux
  if command -v tmux &> /dev/null; then
    print_success "tmux already installed ($(tmux -V))"
  else
    print_info "Installing tmux..."
    if install_package tmux; then
      print_success "tmux installed successfully"
    else
      print_error "Failed to install tmux"
      exit 1
    fi
  fi

  # Check and install lazygit (if requested)
  if [[ "$INSTALL_LAZYGIT" == "yes" ]]; then
    if command -v lazygit &> /dev/null; then
      print_success "lazygit already installed"
    else
      print_info "Installing lazygit..."
      PLATFORM=$(detect_platform)

      case "$PLATFORM" in
        macos)
          if install_package lazygit; then
            print_success "lazygit installed successfully"
          else
            print_warning "Failed to install lazygit (optional)"
          fi
          ;;
        debian|wsl)
          print_info "Installing lazygit from GitHub releases..."
          LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
          curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
          tar xf lazygit.tar.gz lazygit
          sudo install lazygit /usr/local/bin
          rm lazygit lazygit.tar.gz
          print_success "lazygit installed successfully"
          ;;
        arch)
          if install_package lazygit; then
            print_success "lazygit installed successfully"
          else
            print_warning "Failed to install lazygit (optional)"
          fi
          ;;
        *)
          print_warning "lazygit installation not supported on this platform. Install manually from: https://github.com/jesseduffield/lazygit"
          ;;
      esac
    fi
  fi

  # Check for Claude CLI
  if command -v claude &> /dev/null; then
    print_success "Claude CLI found"
  else
    print_warning "Claude CLI not found"
    print_info "Install from: https://github.com/anthropics/claude-cli"
    print_info "The workspace will still be created, but the AI pane will be empty."
  fi

  echo ""
}

# ========================================
# Configuration Deployment
# ========================================

backup_configs() {
  print_header "Backing Up Existing Configurations"

  local timestamp=$(date +%Y%m%d_%H%M%S)

  # Backup tmux.conf
  if [[ -f ~/.tmux.conf ]]; then
    cp ~/.tmux.conf ~/.tmux.conf.backup_$timestamp
    print_success "Backed up ~/.tmux.conf to ~/.tmux.conf.backup_$timestamp"
  fi

  # Backup shell configs
  if [[ -f ~/.zshrc ]]; then
    cp ~/.zshrc ~/.zshrc.backup_$timestamp
    print_success "Backed up ~/.zshrc to ~/.zshrc.backup_$timestamp"
  fi

  if [[ -f ~/.bashrc ]]; then
    cp ~/.bashrc ~/.bashrc.backup_$timestamp
    print_success "Backed up ~/.bashrc to ~/.bashrc.backup_$timestamp"
  fi

  echo ""
}

apply_theme() {
  local config_file=$1
  local theme=$2

  case $theme in
    blue)
      sed -i.tmp "s/colour208/colour39/g" "$config_file"
      ;;
    green)
      sed -i.tmp "s/colour208/colour46/g" "$config_file"
      ;;
    monochrome)
      sed -i.tmp "s/colour208/colour255/g" "$config_file"
      ;;
    default)
      # Already orange (colour208)
      ;;
  esac

  rm -f "${config_file}.tmp"
}

install_tmux_config() {
  print_header "Installing Tmux Configuration"

  # Copy tmux config
  local tmux_config_src
  tmux_config_src="$(resolve_asset_path configs/tmux.conf || true)"
  if [[ -z "$tmux_config_src" ]]; then
    print_error "Unable to locate configs/tmux.conf (local or remote)"
    print_info "Set TMUX_AI_WORKSPACE_BASE_URL if using a fork."
    exit 1
  fi

  cp "$tmux_config_src" ~/.tmux.conf
  print_success "Installed ~/.tmux.conf"

  # Apply color theme
  apply_theme ~/.tmux.conf "$THEME"
  print_success "Applied $THEME theme"

  # Install TPM if requested
  if [[ "$INSTALL_TPM" != "no" ]]; then
    if [[ ! -d ~/.tmux/plugins/tpm ]]; then
      print_info "Installing TPM (Tmux Plugin Manager)..."
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      print_success "TPM installed"
    else
      print_success "TPM already installed"
    fi

    if [[ "$INSTALL_TPM" == "minimal" ]]; then
      # Remove plugin lines except TPM itself
      sed -i.tmp "/set -g @plugin 'tmux-plugins\/tmux-sensible'/d" ~/.tmux.conf
      sed -i.tmp "/set -g @plugin 'tmux-plugins\/tmux-yank'/d" ~/.tmux.conf
      sed -i.tmp "/set -g @plugin 'tmux-plugins\/tmux-resurrect'/d" ~/.tmux.conf
      rm -f ~/.tmux.conf.tmp
      print_success "Configured for minimal TPM (no additional plugins)"
    fi
  else
    # Remove all TPM-related lines
    sed -i.tmp "/# TPM Plugin Manager/,/run '~\/.tmux\/plugins\/tpm\/tpm'/d" ~/.tmux.conf
    rm -f ~/.tmux.conf.tmp
    print_success "Skipped TPM installation"
  fi

  echo ""
}

detect_shell_type() {
  if [[ "$SHELL_TYPE" == "auto" ]]; then
    if [[ "$SHELL" == *"zsh"* ]]; then
      echo "zsh"
    elif [[ "$SHELL" == *"bash"* ]]; then
      echo "bash"
    else
      # Default to bash
      echo "bash"
    fi
  else
    echo "$SHELL_TYPE"
  fi
}

install_shell_function() {
  local shell_config=$1
  local shell_name=$2

  print_info "Configuring $shell_name ($shell_config)..."

  # Check if ai() function already exists
  if grep -q "^ai()" "$shell_config" 2>/dev/null; then
    print_warning "ai() function already exists in $shell_config"
    read -p "Overwrite? [y/N]: " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
      return
    fi
    # Remove old function
    sed -i.tmp '/^ai()/,/^}/d' "$shell_config"
    rm -f "${shell_config}.tmp"
  fi

  # Append ai function
  cat >> "$shell_config" << 'EOF'

# ========================================
# tmux-ai-workspace
# ========================================
EOF

  # Set environment variables for customization
  cat >> "$shell_config" << EOF
export AI_CLAUDE_MODE="$CLAUDE_MODE"

EOF

  # Append the ai function from the script
  local ai_function_src
  ai_function_src="$(resolve_asset_path scripts/ai-function.sh || true)"
  if [[ -z "$ai_function_src" ]]; then
    print_error "Unable to locate scripts/ai-function.sh (local or remote)"
    print_info "Set TMUX_AI_WORKSPACE_BASE_URL if using a fork."
    exit 1
  fi

  sed -n '/^ai()/,/^}/p' "$ai_function_src" >> "$shell_config"

  # Add aliases
  cat >> "$shell_config" << 'EOF'

# Tmux helper aliases
alias ta='tmux attach'
alias tl='tmux ls'
alias tk='tmux kill-session -t'
EOF

  print_success "Configured $shell_name"
}

install_ai_function() {
  print_header "Installing Shell Integration"

  local detected_shell=$(detect_shell_type)

  case $detected_shell in
    zsh)
      install_shell_function ~/.zshrc "zsh"
      ;;
    bash)
      install_shell_function ~/.bashrc "bash"
      ;;
    both)
      install_shell_function ~/.zshrc "zsh"
      install_shell_function ~/.bashrc "bash"
      ;;
  esac

  echo ""
}

# ========================================
# Verification
# ========================================

verify_installation() {
  print_header "Verifying Installation"

  local all_good=true

  # Check tmux config
  if [[ -f ~/.tmux.conf ]]; then
    print_success "~/.tmux.conf exists"
  else
    print_error "~/.tmux.conf not found"
    all_good=false
  fi

  # Check shell config
  local detected_shell=$(detect_shell_type)
  case $detected_shell in
    zsh)
      if grep -q "^ai()" ~/.zshrc 2>/dev/null; then
        print_success "ai() function found in ~/.zshrc"
      else
        print_error "ai() function not found in ~/.zshrc"
        all_good=false
      fi
      ;;
    bash)
      if grep -q "^ai()" ~/.bashrc 2>/dev/null; then
        print_success "ai() function found in ~/.bashrc"
      else
        print_error "ai() function not found in ~/.bashrc"
        all_good=false
      fi
      ;;
    both)
      if grep -q "^ai()" ~/.zshrc 2>/dev/null && grep -q "^ai()" ~/.bashrc 2>/dev/null; then
        print_success "ai() function found in both shell configs"
      else
        print_error "ai() function not found in one or more shell configs"
        all_good=false
      fi
      ;;
  esac

  # Check dependencies
  if command -v tmux &> /dev/null; then
    print_success "tmux is installed"
  else
    print_error "tmux is not installed"
    all_good=false
  fi

  echo ""

  if $all_good; then
    print_success "Installation verified successfully!"
  else
    print_error "Some verification checks failed. Please review the output above."
  fi

  echo ""
}

# ========================================
# Post-Install Instructions
# ========================================

show_next_steps() {
  print_header "🎉 Installation Complete!"

  echo "Next steps:"
  echo ""
  echo "  1. Reload your shell configuration:"

  local detected_shell=$(detect_shell_type)
  case $detected_shell in
    zsh)
      echo "     ${GREEN}source ~/.zshrc${NC}"
      ;;
    bash)
      echo "     ${GREEN}source ~/.bashrc${NC}"
      ;;
    both)
      echo "     ${GREEN}source ~/.zshrc${NC}  (for zsh)"
      echo "     ${GREEN}source ~/.bashrc${NC}  (for bash)"
      ;;
  esac

  echo ""
  echo "  2. Launch your AI workspace:"
  echo "     ${GREEN}ai${NC}"
  echo ""

  if [[ "$INSTALL_TPM" == "yes" ]]; then
    echo "  3. Install tmux plugins:"
    echo "     - Start tmux: ${GREEN}tmux${NC}"
    echo "     - Press: ${GREEN}Ctrl+b${NC} then ${GREEN}I${NC} (capital i)"
    echo "     - Wait for plugins to install"
    echo ""
  fi

  echo "Useful commands:"
  echo "  • ${GREEN}ai${NC}      - Start AI workspace"
  echo "  • ${GREEN}ta${NC}      - Attach to tmux session"
  echo "  • ${GREEN}tl${NC}      - List tmux sessions"
  echo "  • ${GREEN}tk <name>${NC} - Kill tmux session"
  echo ""
  echo "Documentation:"
  if [[ -f "$ASSET_ROOT/README.md" ]]; then
    echo "  • README: $ASSET_ROOT/README.md"
    echo "  • Customization: $ASSET_ROOT/docs/CUSTOMIZATION.md"
    echo "  • Troubleshooting: $ASSET_ROOT/docs/TROUBLESHOOTING.md"
  else
    echo "  • README: $BASE_URL/README.md"
    echo "  • Customization: $BASE_URL/docs/CUSTOMIZATION.md"
    echo "  • Troubleshooting: $BASE_URL/docs/TROUBLESHOOTING.md"
  fi
  echo ""
  echo -e "${ORANGE}Happy coding! 🚀${NC}"
  echo ""
}

# ========================================
# Main Installation Flow
# ========================================

main() {
  ask_questions
  check_platform
  install_dependencies
  backup_configs
  install_tmux_config
  install_ai_function
  verify_installation
  show_next_steps
}

# Run main function
main "$@"
