# Installation Guide

This guide provides detailed installation instructions for tmux-ai-workspace.

## Table of Contents

- [Quick Install](#quick-install)
- [Manual Install](#manual-install)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Configuration-Driven Install](#configuration-driven-install)
- [Verifying Installation](#verifying-installation)
- [Post-Install Setup](#post-install-setup)

## Quick Install

### One-Line Remote Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh)
```

This will:
1. Download and run the installer
2. Ask 5 configuration questions
3. Install dependencies
4. Configure tmux and your shell
5. Display next steps

### Secure Alternative

If you prefer to review the script before running:

```bash
# Download the installer
curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh -o install.sh

# Review the script
less install.sh

# Optional: Verify checksum (if available)
curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh.sha256 -o install.sh.sha256
sha256sum -c install.sh.sha256

# Make executable and run
chmod +x install.sh
./install.sh
```

## Manual Install

For complete control over the installation process:

### Step 1: Clone Repository

```bash
git clone https://github.com/USER/tmux-ai-workspace.git
cd tmux-ai-workspace
```

### Step 2: Run Installer

```bash
./install.sh
```

The installer will guide you through 5 questions:

1. **Claude CLI mode**: How Claude should run (dangerous/safe/custom)
2. **Install lazygit**: Whether to install the Git UI
3. **Color theme**: Choose your tmux color scheme
4. **TPM plugins**: Install Tmux Plugin Manager and plugins
5. **Shell configuration**: Which shell(s) to configure

### Step 3: Follow Post-Install Instructions

The installer will display next steps, including reloading your shell config.

## Platform-Specific Instructions

### macOS

**Prerequisites:**
- Homebrew installed ([install here](https://brew.sh))
- macOS 10.15 or later recommended

**Installation:**
```bash
# Ensure Homebrew is up to date
brew update

# Run installer
bash <(curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh)
```

**Notes:**
- Default shell is zsh on macOS 10.15+
- tmux and lazygit install via Homebrew
- Claude CLI must be installed separately

### Ubuntu/Debian

**Prerequisites:**
- Ubuntu 20.04+ or Debian 10+ recommended
- `sudo` access for package installation

**Installation:**
```bash
# Update package list
sudo apt-get update

# Run installer
bash <(curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh)
```

**Notes:**
- Default shell is typically bash
- tmux installs via apt
- lazygit installs from GitHub releases
- May need `curl` and `tar`: `sudo apt-get install curl tar`

### Fedora/RHEL

**Prerequisites:**
- Fedora 35+ or RHEL 8+ recommended
- `sudo` access for package installation

**Installation:**
```bash
# Update package list
sudo yum update  # or: sudo dnf update

# Run installer
bash <(curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh)
```

**Notes:**
- Default shell is bash
- tmux installs via yum/dnf
- lazygit may require EPEL or manual installation

### Arch Linux

**Prerequisites:**
- Arch Linux (any recent version)
- `sudo` access for package installation

**Installation:**
```bash
# Update package database
sudo pacman -Syu

# Run installer
bash <(curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh)
```

**Notes:**
- Default shell is bash
- tmux and lazygit install via pacman
- AUR packages not required

### WSL2 (Windows Subsystem for Linux)

**Prerequisites:**
- WSL2 with Ubuntu 20.04+ recommended
- Windows 10 version 2004 or later

**Installation:**
```bash
# Inside your WSL2 terminal
sudo apt-get update

# Run installer
bash <(curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh)
```

**Notes:**
- Detected as Ubuntu/Debian platform
- Clipboard integration may require X server
- Default shell depends on WSL distribution

## Configuration-Driven Install

For automated or scripted installations, you can pre-set environment variables:

```bash
# Set configuration variables
export AI_CLAUDE_MODE="dangerous"     # or "safe" or custom flags
export AI_INSTALL_LAZYGIT="yes"       # or "no"
export AI_THEME="default"             # or "blue", "green", "monochrome"
export AI_INSTALL_TPM="yes"           # or "minimal", "no"
export AI_SHELL_TYPE="auto"           # or "zsh", "bash", "both"

# Run installer (will use these values)
./install.sh
```

**Note:** This feature is planned for v1.1. Current version always runs interactively.

## Verifying Installation

### Check Files

```bash
# Verify tmux config exists
ls -la ~/.tmux.conf

# Verify shell config contains ai() function
grep "ai()" ~/.zshrc  # or ~/.bashrc

# Check for TPM (if installed)
ls -la ~/.tmux/plugins/tpm
```

### Test Commands

```bash
# Reload shell
source ~/.zshrc  # or ~/.bashrc

# Check if ai command is available
type ai

# Check tmux version
tmux -V

# Check Claude CLI (if installed)
claude --version

# Check lazygit (if installed)
lazygit --version
```

### Test Workspace

```bash
# Launch AI workspace
ai

# You should see:
# - 3 panes created
# - Claude CLI running in left pane (if installed)
# - Terminal in top-right pane
# - lazygit in bottom-right pane (if installed)

# Detach from session
# Press: Ctrl+b then d
```

## Post-Install Setup

### Install TPM Plugins

If you chose to install TPM:

1. Start tmux: `tmux`
2. Press: `Ctrl+b` then `I` (capital i)
3. Wait for plugins to install (5-10 seconds)
4. You should see a success message

### Install Claude CLI

If not already installed:

```bash
# Follow instructions at:
# https://github.com/anthropics/claude-cli

# On macOS:
brew install anthropic/claude/claude-cli

# Verify installation:
claude --version
```

### Configure Claude API Key

```bash
# Set your API key
claude auth login

# Or set environment variable:
export ANTHROPIC_API_KEY="your-key-here"
```

### Customize Your Setup

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for:
- Changing color themes
- Modifying pane layouts
- Adding custom keybindings
- Integrating other tools

## Troubleshooting Installation

### "brew: command not found" (macOS)

Install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### "sudo: not available" (Linux)

Install sudo:
```bash
# As root user:
apt-get install sudo
# Then add your user to sudo group:
usermod -aG sudo YOUR_USERNAME
```

### "curl: command not found"

Install curl:
```bash
# Ubuntu/Debian:
sudo apt-get install curl

# Fedora/RHEL:
sudo yum install curl

# Arch:
sudo pacman -S curl
```

### Installation Fails on Package Installation

Try updating your package manager:
```bash
# macOS:
brew update && brew doctor

# Ubuntu/Debian:
sudo apt-get update && sudo apt-get upgrade

# Fedora/RHEL:
sudo yum update

# Arch:
sudo pacman -Syu
```

### Shell Config Not Updated

Manually add the ai() function:
```bash
# Edit your shell config
nano ~/.zshrc  # or ~/.bashrc

# Add at the end:
source /path/to/tmux-ai-workspace/scripts/ai-function.sh
```

### Permission Denied Errors

Ensure installer is executable:
```bash
chmod +x install.sh
./install.sh
```

## Next Steps

- Read [CUSTOMIZATION.md](CUSTOMIZATION.md) to personalize your workspace
- Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Try the `ai` command to launch your workspace
- Learn tmux keybindings (press `Ctrl+b` then `?` for help)

---

Need more help? [Open an issue](https://github.com/USER/tmux-ai-workspace/issues) on GitHub.
