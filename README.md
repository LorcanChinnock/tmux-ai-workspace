# tmux-ai-workspace

> Streamlined tmux workspace for AI-assisted development with Claude CLI

A one-command setup for an optimized tmux environment designed for AI pair programming. Features a 3-pane layout with Claude CLI, terminal, and git UI, all with mouse support and vim keybindings.

<img width="1917" height="1142" alt="Screenshot 2026-02-05 at 22 44 16" src="https://github.com/user-attachments/assets/174b4062-1e2d-4866-88ec-4bc09d2d1760" />

## Features

- **🤖 AI-Optimized Layout**: 3-pane workspace (Claude CLI 50%, Terminal 25%, Git UI 25%)
- **🖱️ Mouse-Enabled**: Click, scroll, and resize panes with your mouse
- **⌨️ Vim Keybindings**: Navigate panes with h/j/k/l
- **🎨 Customizable Themes**: Orange (default), blue, green, or monochrome
- **🔧 Interactive Setup**: Guided installation with sensible defaults
- **🌍 Multi-Platform**: macOS, Ubuntu/Debian, Fedora/RHEL, Arch Linux, WSL2
- **📦 Plugin Support**: Optional TPM integration for tmux-yank, tmux-resurrect, etc.

## Quick Install

### One-Line Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/USER/tmux-ai-workspace/main/install.sh)
```

### Manual Install

```bash
git clone https://github.com/USER/tmux-ai-workspace.git
cd tmux-ai-workspace
./install.sh
```

The installer will ask you 5 quick questions to customize your setup, then handle everything automatically.

## Requirements

### Required
- **tmux** 3.0+ (installed automatically)
- **bash** or **zsh**
- Platform package manager (brew/apt/yum/pacman)

### Optional
- **Claude CLI** - [Install guide](https://github.com/anthropics/claude-cli)
- **lazygit** - Installed automatically if you choose "Yes" during setup

## Usage

After installation, launch your AI workspace:

```bash
ai
```

This creates a tmux session with:
- **Left pane (50%)**: Claude CLI in your chosen mode (dangerous/safe/custom)
- **Top-right pane (25%)**: Terminal for running commands
- **Bottom-right pane (25%)**: lazygit for version control

### Workspace Commands

```bash
ai           # Launch AI workspace
ta           # Attach to existing tmux session
tl           # List all tmux sessions
tk <name>    # Kill a specific tmux session
```

### Tmux Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+b` | Prefix key (press before other commands) |
| `h/j/k/l` | Navigate panes (vim-style) |
| `\|` | Split pane vertically |
| `-` | Split pane horizontally |
| `r` | Reload tmux config |
| `S` | Synchronize panes (type in all at once) |
| `d` | Detach from session |
| `[` | Enter copy mode (use vim keys to navigate) |

**Mouse Support**: Click panes to select, drag borders to resize, scroll to navigate history.

## Platform Support

| Platform | Status | Package Manager |
|----------|--------|----------------|
| macOS | ✅ Tested | Homebrew |
| Ubuntu/Debian | ✅ Tested | apt |
| Fedora/RHEL | ✅ Tested | yum/dnf |
| Arch Linux | ✅ Tested | pacman |
| WSL2 | ✅ Tested | apt (via Ubuntu) |

## Customization

See [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for:
- Changing color themes
- Modifying pane layout percentages
- Customizing Claude CLI flags
- Adding custom panes
- Configuring keybindings

### Quick Theme Change

Edit `~/.tmux.conf` and change `colour208` to:
- **Blue**: `colour39`
- **Green**: `colour46`
- **Monochrome**: `colour255`

Then reload: `tmux source ~/.tmux.conf`

## Troubleshooting

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions.

### Quick Fixes

**"ai: command not found"**
```bash
source ~/.zshrc  # or ~/.bashrc for bash
```

**Claude CLI not starting**
- Install Claude CLI: https://github.com/anthropics/claude-cli
- Check it's in your PATH: `which claude`

**lazygit not showing**
- Install manually: `brew install lazygit` (macOS)
- Or see: https://github.com/jesseduffield/lazygit#installation

**TPM plugins not working**
- Start tmux: `tmux`
- Press `Ctrl+b` then `I` (capital i)
- Wait for installation to complete

## Uninstall

```bash
cd tmux-ai-workspace
./uninstall.sh
```

The uninstaller will:
- Remove the `ai()` function from your shell config
- Optionally remove `~/.tmux.conf`
- Optionally restore from backups
- Optionally remove TPM

All original files are backed up with timestamps before any changes.

## Project Structure

```
tmux-ai-workspace/
├── README.md              # This file
├── LICENSE                # MIT License
├── install.sh             # Interactive installer
├── uninstall.sh           # Removal script
├── configs/
│   └── tmux.conf          # Tmux configuration template
├── scripts/
│   ├── ai-function.sh     # Shell function for ai() command
│   └── detect-platform.sh # Platform detection utilities
└── docs/
    ├── INSTALLATION.md    # Detailed installation guide
    ├── CUSTOMIZATION.md   # Customization guide
    └── TROUBLESHOOTING.md # Common issues and fixes
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Security

The installer:
- Uses HTTPS for all downloads
- Backs up all existing configs before making changes
- Only requests `sudo` when absolutely necessary
- Can be reviewed before running (see [INSTALLATION.md](docs/INSTALLATION.md))

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [Claude CLI](https://github.com/anthropics/claude-cli) - Anthropic's Claude command-line interface
- [lazygit](https://github.com/jesseduffield/lazygit) - Simple terminal UI for git
- [TPM](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager

---

**Happy coding! 🚀**

If you find this useful, please star the repo and share it with others!
