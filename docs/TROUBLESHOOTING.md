# Troubleshooting Guide

Common issues and solutions for tmux-ai-workspace.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Command Not Found](#command-not-found)
- [Claude CLI Issues](#claude-cli-issues)
- [Lazygit Issues](#lazygit-issues)
- [Tmux Issues](#tmux-issues)
- [TPM Plugin Issues](#tpm-plugin-issues)
- [Shell Issues](#shell-issues)
- [Display Issues](#display-issues)
- [Performance Issues](#performance-issues)

## Installation Issues

### "Package manager not found"

**Problem:** Installer can't find brew/apt/yum/pacman

**Solution:**
```bash
# macOS - Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ubuntu/Debian - apt should be pre-installed
which apt-get

# Fedora/RHEL - Install dnf
sudo yum install dnf

# Arch - pacman should be pre-installed
which pacman
```

### "Permission denied" during install

**Problem:** Can't execute installer script

**Solution:**
```bash
chmod +x install.sh
./install.sh
```

### Installation succeeds but nothing changes

**Problem:** Shell config not reloaded

**Solution:**
```bash
# Reload your shell configuration
source ~/.zshrc     # for zsh
source ~/.bashrc    # for bash

# Or restart your terminal
```

### "curl: command not found"

**Problem:** curl not installed

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install curl

# Fedora/RHEL
sudo yum install curl

# Arch
sudo pacman -S curl

# macOS (usually pre-installed)
brew install curl
```

## Command Not Found

### "ai: command not found"

**Problem:** Shell can't find the ai() function

**Solution 1 - Reload shell:**
```bash
source ~/.zshrc     # for zsh
source ~/.bashrc    # for bash
```

**Solution 2 - Check if function exists:**
```bash
# Should show the function definition
type ai

# If not found, check your shell config
grep "ai()" ~/.zshrc
grep "ai()" ~/.bashrc
```

**Solution 3 - Manually add:**
```bash
# Add to your shell config
echo 'source /path/to/tmux-ai-workspace/scripts/ai-function.sh' >> ~/.zshrc

# Reload
source ~/.zshrc
```

### "ta/tl/tk: command not found"

**Problem:** Aliases not loaded

**Solution:**
Same as above - reload shell configuration or check that aliases are defined in your shell config file.

## Claude CLI Issues

### "claude: command not found"

**Problem:** Claude CLI not installed or not in PATH

**Solution:**
```bash
# Check if installed
which claude

# If not found, install:
# macOS
brew install anthropic/claude/claude-cli

# Other platforms - follow instructions at:
# https://github.com/anthropics/claude-cli

# Verify installation
claude --version
```

### Claude pane is empty/blank

**Problem:** Claude not starting or not in PATH

**Solution:**
```bash
# Test Claude manually
claude --version

# Check PATH
echo $PATH | grep claude

# Add to PATH if needed (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"

# Check tmux session manually
tmux attach -t ai-coding
# Look at the Claude pane - any error messages?
```

### "ANTHROPIC_API_KEY not found"

**Problem:** Claude CLI not authenticated

**Solution:**
```bash
# Login to Claude
claude auth login

# Or set API key manually
export ANTHROPIC_API_KEY="your-key-here"

# Add to shell config for persistence
echo 'export ANTHROPIC_API_KEY="your-key-here"' >> ~/.zshrc
```

### Claude starts in wrong mode

**Problem:** Expected dangerous mode but getting safe mode (or vice versa)

**Solution:**
```bash
# Check current setting
echo $AI_CLAUDE_MODE

# Change in shell config (~/.zshrc or ~/.bashrc)
export AI_CLAUDE_MODE="dangerous"  # or "safe"

# Reload
source ~/.zshrc

# Or override for one session
AI_CLAUDE_MODE="safe" ai
```

## Lazygit Issues

### "lazygit: command not found"

**Problem:** lazygit not installed

**Solution:**
```bash
# macOS
brew install lazygit

# Ubuntu/Debian
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

# Arch
sudo pacman -S lazygit

# Verify
lazygit --version
```

### Lazygit pane shows error

**Problem:** lazygit crashes or shows errors

**Solution:**
```bash
# Check if in a git repository
git status

# lazygit requires a git repository
# If not in one, the pane will show an error

# Start ai() from within a git repo
cd ~/my-git-project
ai
```

### Lazygit colors look wrong

**Problem:** Color scheme issues

**Solution:**
```bash
# Check terminal color support
echo $TERM

# Should be "screen-256color" or similar
# If not, tmux.conf may not be loaded

# Reload tmux config
tmux source ~/.tmux.conf
```

## Tmux Issues

### "tmux: command not found"

**Problem:** tmux not installed

**Solution:**
```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt-get install tmux

# Fedora/RHEL
sudo yum install tmux

# Arch
sudo pacman -S tmux

# Verify
tmux -V
```

### Can't create session - already exists

**Problem:** Session name conflict

**Solution:**
```bash
# Kill existing session
tmux kill-session -t ai-coding

# Or attach to it instead
tmux attach -t ai-coding

# The ai() function should handle this automatically
# If not, check if the function is correct
type ai
```

### Panes have wrong layout

**Problem:** Layout doesn't match expected 3-pane setup

**Solution:**
```bash
# Kill session and restart
tmux kill-session -t ai-coding
ai

# If still wrong, check ai() function
type ai | less

# Should see split-window commands
```

### Mouse doesn't work

**Problem:** Can't click or scroll in tmux

**Solution:**
```bash
# Check if mouse is enabled
tmux show -g mouse

# Should show: mouse on

# If not, edit ~/.tmux.conf
echo "set -g mouse on" >> ~/.tmux.conf

# Reload config
tmux source ~/.tmux.conf

# Or restart tmux
tmux kill-server
ai
```

### Vim keybindings don't work

**Problem:** h/j/k/l don't navigate panes

**Solution:**
```bash
# Check if mode-keys is set
tmux show -g mode-keys

# Should show: mode-keys vi

# If not, edit ~/.tmux.conf
echo "setw -g mode-keys vi" >> ~/.tmux.conf

# Also check custom bindings exist
grep "bind h select-pane" ~/.tmux.conf
```

### Can't detach from tmux

**Problem:** Ctrl+b d doesn't work

**Solution:**
```bash
# Check if prefix is correct
tmux show -g prefix

# Should show: prefix C-b

# Make sure you're pressing Ctrl+b, then releasing, then pressing d
# NOT Ctrl+b+d all at once

# Alternative: type in a pane
tmux detach
```

## TPM Plugin Issues

### "TPM not found" or plugins don't work

**Problem:** TPM not installed or initialized

**Solution:**
```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Check ~/.tmux.conf has TPM section
grep "tpm/tpm" ~/.tmux.conf

# Should see: run '~/.tmux/plugins/tpm/tpm'

# Reload tmux config
tmux source ~/.tmux.conf

# Install plugins
# In tmux, press: Ctrl+b then I (capital i)
```

### Plugins installed but not working

**Problem:** Plugins installed but features missing

**Solution:**
```bash
# Update plugins
# In tmux, press: Ctrl+b then U (capital u)

# Manually update
cd ~/.tmux/plugins/tpm
git pull

# Re-run TPM installer
~/.tmux/plugins/tpm/bin/install_plugins
```

### Copy/paste doesn't work (tmux-yank)

**Problem:** Can't copy from tmux to system clipboard

**Solution:**
```bash
# Check if tmux-yank is installed
ls ~/.tmux/plugins/tmux-yank

# Install if missing
# In tmux: Ctrl+b then I

# On macOS, need reattach-to-user-namespace
brew install reattach-to-user-namespace

# On Linux, need xclip or xsel
sudo apt-get install xclip  # Ubuntu/Debian
sudo yum install xclip      # Fedora/RHEL
sudo pacman -S xclip        # Arch
```

## Shell Issues

### Wrong shell detected

**Problem:** Installer configures bash but you use zsh (or vice versa)

**Solution:**
```bash
# Check your shell
echo $SHELL

# Re-run installer and select correct shell
./install.sh

# Or manually add to correct shell config
# If using zsh:
source /path/to/tmux-ai-workspace/scripts/ai-function.sh >> ~/.zshrc

# If using bash:
source /path/to/tmux-ai-workspace/scripts/ai-function.sh >> ~/.bashrc
```

### Environment variables not set

**Problem:** AI_CLAUDE_MODE or other variables not working

**Solution:**
```bash
# Check if variables are set
env | grep AI_

# Should see:
# AI_SESSION_NAME=ai-coding
# AI_CLAUDE_MODE=dangerous

# If not, add to shell config
echo 'export AI_CLAUDE_MODE="dangerous"' >> ~/.zshrc
echo 'export AI_SESSION_NAME="ai-coding"' >> ~/.zshrc

# Reload
source ~/.zshrc
```

### Shell config conflicts

**Problem:** Other tools break after installation

**Solution:**
```bash
# Check backup files
ls -la ~/.zshrc.backup_*
ls -la ~/.bashrc.backup_*

# Restore if needed
cp ~/.zshrc.backup_YYYYMMDD_HHMMSS ~/.zshrc

# Or manually edit and remove tmux-ai-workspace section
nano ~/.zshrc
# Delete from "# tmux-ai-workspace" to "alias tk='tmux kill-session -t'"
```

## Display Issues

### Pane titles not showing

**Problem:** Can't see "AI CLI", "Terminal", "Git" titles

**Solution:**
```bash
# Check pane border status
tmux show -g pane-border-status

# Should show: pane-border-status top

# If not, add to ~/.tmux.conf
echo "set -g pane-border-status top" >> ~/.tmux.conf
echo "set -g pane-border-format ' #{pane_index} #{pane_title} '" >> ~/.tmux.conf

# Reload
tmux source ~/.tmux.conf
```

### Colors look wrong/washed out

**Problem:** 256 colors not working

**Solution:**
```bash
# Check terminal color support
echo $TERM

# In tmux, should be "screen-256color"
# Outside tmux, should be "xterm-256color" or similar

# Edit ~/.tmux.conf
echo 'set -g default-terminal "screen-256color"' >> ~/.tmux.conf
echo 'set -ga terminal-overrides ",xterm-256color:Tc"' >> ~/.tmux.conf

# Reload
tmux kill-server
ai
```

### Status bar missing or wrong

**Problem:** Status bar at bottom doesn't show or looks different

**Solution:**
```bash
# Check if status bar is enabled
tmux show -g status

# Should show: status on

# Check styling
grep "status-style" ~/.tmux.conf

# Should see color configuration
# Re-install tmux config if missing
cp /path/to/tmux-ai-workspace/configs/tmux.conf ~/.tmux.conf
tmux source ~/.tmux.conf
```

### Unicode characters broken

**Problem:** Symbols or special characters display incorrectly

**Solution:**
```bash
# Check locale
locale

# Should include UTF-8 (e.g., en_US.UTF-8)

# Set UTF-8 locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Add to shell config
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc
echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
```

## Performance Issues

### Tmux is slow/laggy

**Problem:** Tmux feels sluggish

**Solution:**
```bash
# Reduce escape time (already in config, but verify)
grep "escape-time" ~/.tmux.conf

# Should be: set -s escape-time 0

# Reduce status update interval
echo "set -g status-interval 5" >> ~/.tmux.conf

# Disable visual activity monitoring
echo "set -g visual-activity off" >> ~/.tmux.conf

# Reload
tmux source ~/.tmux.conf
```

### High CPU usage

**Problem:** tmux or processes using too much CPU

**Solution:**
```bash
# Check what's running in each pane
tmux list-panes -a -F "#{pane_id} #{pane_current_command}"

# Claude CLI might use CPU when processing
# This is normal

# Check for runaway processes
top
# or
htop

# Kill specific pane if needed
tmux kill-pane -t ai-coding:1.1
```

### Memory issues

**Problem:** tmux using too much memory

**Solution:**
```bash
# Reduce scrollback buffer
echo "set -g history-limit 10000" >> ~/.tmux.conf

# Was: 50000 (can make it smaller if needed)

# Clear history in running session
# In tmux, press: Ctrl+b then :
# Then type: clear-history

# Reload config
tmux source ~/.tmux.conf
```

## Getting More Help

If you're still experiencing issues:

1. **Check tmux version**: `tmux -V` (should be 3.0+)
2. **Check logs**: tmux doesn't log by default, but check your shell history
3. **Test in isolation**: Try `tmux` alone without the ai() function
4. **Reset everything**:
   ```bash
   ./uninstall.sh
   rm ~/.tmux.conf
   rm -rf ~/.tmux/plugins
   ./install.sh
   ```

5. **Report an issue**: [GitHub Issues](https://github.com/USER/tmux-ai-workspace/issues)
   - Include: OS, tmux version, shell, error messages
   - Include output of: `tmux show -g` and `type ai`

---

**Still stuck?** Join the discussion on [GitHub Discussions](https://github.com/USER/tmux-ai-workspace/discussions)
