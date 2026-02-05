# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tmux-ai-workspace is a shell-based installer that creates an optimized tmux environment for AI pair programming. It sets up a 3-pane layout with Claude CLI, a terminal, and git UI (lazygit), with mouse support and vim keybindings.

## Core Architecture

### Installation Flow
The installer (`install.sh`) orchestrates the entire setup process:
1. Interactive Q&A to gather user preferences (Claude mode, lazygit, theme, TPM, shell)
2. Platform detection via `scripts/detect-platform.sh`
3. Dependency installation (tmux, optionally lazygit)
4. Configuration deployment (tmux.conf with theme application)
5. Shell integration (injecting the `ai()` function)
6. Verification and next steps

### Key Components

**Shell Function (`scripts/ai-function.sh`)**
- Defines the `ai()` function that creates the tmux workspace
- Creates a 3-pane tmux layout: left 50% (Claude CLI), top-right 25% (terminal), bottom-right 25% (lazygit)
- Dynamically names sessions as "AI-{folder-name}" based on current directory
- Launches Claude CLI based on `AI_CLAUDE_MODE` environment variable
- All panes start in current directory (`$PWD`)

**Platform Detection (`scripts/detect-platform.sh`)**
- Detects OS: macOS, WSL, Debian, RedHat, Arch
- Provides package manager abstraction for cross-platform installation
- Functions: `detect_platform()`, `install_package()`, `check_package_manager()`

**Tmux Config (`configs/tmux.conf`)**
- Template file deployed to `~/.tmux.conf`
- Default orange theme (colour208) that can be replaced during installation
- Configured for mouse support, vim keybindings, and pane titles
- Optional TPM plugin integration

**Uninstaller (`uninstall.sh`)**
- Removes shell function from .zshrc/.bashrc
- Optionally removes tmux.conf and TPM
- Creates backups before any destructive operations

## Development Commands

### Testing Installation
```bash
# Run installer
./install.sh

# Test the ai() function (after sourcing shell config)
source ~/.zshrc  # or ~/.bashrc
ai

# Verify tmux config
tmux source ~/.tmux.conf
```

### Testing Uninstallation
```bash
./uninstall.sh
```

### Platform Detection Testing
```bash
# Source the detection script
source scripts/detect-platform.sh

# Test functions
detect_platform
check_package_manager
```

## Important Implementation Details

### Color Theme System
Theme colors are applied via `apply_theme()` function in `install.sh` using `sed` to replace colour208:
- Blue: colour39
- Green: colour46
- Monochrome: colour255
- Default: colour208 (orange)

### Shell Configuration Pattern
The `ai()` function is injected into shell configs with this structure:
```bash
# ========================================
# tmux-ai-workspace
# ========================================
export AI_CLAUDE_MODE="dangerous"  # or "safe" or custom flags

ai() {
  # function body from scripts/ai-function.sh
  # Session name is dynamically created as "AI-{folder-name}"
}

# Tmux helper aliases
alias ta='tmux attach'
alias tl='tmux ls'
alias tk='tmux kill-session -t'
```

### Tmux Pane Layout Logic
```bash
# Create base session
tmux new-session -d -s "$session_name" -n "workspace" -c "$start_dir"

# Split vertically (left 50%, right 50%)
tmux split-window -h -t "$session_name:1" -c "$start_dir"

# Split right pane horizontally (top 50%, bottom 50% of right side)
tmux split-window -v -t "$session_name:1.2" -c "$start_dir"

# Result: 1.1 (50%), 1.2 (25%), 1.3 (25%)
```

### Backup Strategy
All original configs are backed up with timestamps before modification:
- `~/.tmux.conf.backup_YYYYMMDD_HHMMSS`
- `~/.zshrc.backup_YYYYMMDD_HHMMSS`
- `~/.bashrc.backup_YYYYMMDD_HHMMSS`

### Platform-Specific Installation

**macOS:** Uses Homebrew for tmux and lazygit

**Debian/Ubuntu/WSL:** Uses apt-get for tmux, downloads lazygit from GitHub releases

**Arch:** Uses pacman for both

**RedHat/Fedora:** Uses yum/dnf (lazygit manual install required)

## Environment Variables

The installer respects these environment variables for customization:
- `AI_CLAUDE_MODE`: Claude CLI flags (default: "dangerous")
- `AI_START_DIR`: Starting directory (default: `$PWD`)

Note: Session names are dynamically generated as "AI-{folder-name}" based on the current directory basename, with special characters sanitized for tmux compatibility.

## Testing Strategy

When making changes:
1. Test on the detected platform first
2. Verify backup files are created with timestamps
3. Test both installation and uninstallation flows
4. Verify shell function works after `source ~/.zshrc`
5. Check tmux config applies correctly: `tmux source ~/.tmux.conf`
6. Test with and without optional dependencies (lazygit, Claude CLI)

## File Modification Rules

### Editing install.sh
- Maintain the Q&A flow structure (5 questions)
- Always source `detect-platform.sh` at the start
- Use helper functions (`print_header`, `print_success`, etc.) for consistent output
- Ensure backups are created before any file modifications

### Editing ai-function.sh
- Keep environment variable defaults at the top
- Maintain current directory context (`$PWD`) for all panes
- Check for command existence before using (`command -v`)
- Preserve pane numbering (1.1, 1.2, 1.3)

### Editing tmux.conf
- Keep colour208 as the base color (replaced by installer)
- Maintain comment structure for easy customization by users
- Keep TPM section at the bottom
- Preserve pane-border-status and pane-border-format for pane titles

### Editing detect-platform.sh
- Return consistent strings: "macos", "wsl", "debian", "redhat", "arch", "unknown"
- Keep package manager abstraction in `install_package()`
- Always provide user feedback in `check_package_manager()`

## Common Pitfalls

1. **sed -i differences**: macOS requires `sed -i.tmp`, Linux uses `sed -i`. The codebase uses `.tmp` extension for cross-platform compatibility.

2. **Shell detection**: Auto-detect uses `$SHELL` variable, which may not reflect the current shell. The installer handles both bash and zsh.

3. **Tmux pane indexing**: Panes are 1-indexed (base-index 1), not 0-indexed. First pane is 1.1, not 1.0.

4. **Claude CLI modes**: "dangerous" mode uses `--dangerously-skip-permissions` flag, "safe" mode has no flags, custom can be any string.

5. **TPM installation**: TPM must be installed before plugins work. The installer clones TPM but users must press `Ctrl+b` then `I` to install plugins.

## Documentation Structure

- `README.md`: User-facing overview, quick start, usage
- `docs/INSTALLATION.md`: Detailed installation guide
- `docs/CUSTOMIZATION.md`: How to customize layouts, themes, keybindings
- `docs/TROUBLESHOOTING.md`: Common issues and fixes
