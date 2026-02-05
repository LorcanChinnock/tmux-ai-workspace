# Customization Guide

This guide shows you how to customize tmux-ai-workspace to fit your preferences.

## Table of Contents

- [Color Themes](#color-themes)
- [Layout Customization](#layout-customization)
- [Claude CLI Configuration](#claude-cli-configuration)
- [Keybindings](#keybindings)
- [Adding Custom Panes](#adding-custom-panes)
- [Shell Integration](#shell-integration)
- [Advanced Customization](#advanced-customization)

## Color Themes

### Changing Themes

The installer offers 4 built-in themes during setup. To change themes after installation:

#### Option 1: Re-run Installer

```bash
cd tmux-ai-workspace
./install.sh
# Choose your new theme when prompted
```

#### Option 2: Manual Edit

Edit `~/.tmux.conf` and replace `colour208` with:

| Theme | Color Code | Description |
|-------|-----------|-------------|
| **Orange** (default) | `colour208` | Warm orange accent |
| **Blue** | `colour39` | Cool blue accent |
| **Green** | `colour46` | Vibrant green accent |
| **Monochrome** | `colour255` | White/grey only |

Example for blue theme:
```bash
# Find and replace in ~/.tmux.conf
sed -i '' 's/colour208/colour39/g' ~/.tmux.conf

# Reload tmux config
tmux source ~/.tmux.conf
```

### Custom Colors

For complete control, edit these lines in `~/.tmux.conf`:

```bash
# Status bar background and foreground
set -g status-style 'bg=colour237 fg=colour255'

# Active pane border
set -g pane-active-border-style 'fg=colour208'

# Current window highlighting
setw -g window-status-current-style 'fg=colour208 bold'
```

**Color Reference:**
- Use `colour0` to `colour255` for 256-color palette
- Or use hex colors: `#ff5733`
- View all colors: Run `tmux-256color-chart.sh` (search online)

### Status Bar Customization

Edit status bar in `~/.tmux.conf`:

```bash
# Left side - show session name
set -g status-left '[#S] '
set -g status-left-length 20

# Right side - show date/time
set -g status-right '%Y-%m-%d %H:%M'

# Examples of other options:
# Show hostname: set -g status-right '#H %Y-%m-%d %H:%M'
# Show load: set -g status-right '#(uptime | cut -d "," -f 3-)'
# Show battery: set -g status-right 'Battery: #{battery_percentage} %Y-%m-%d %H:%M'
```

## Layout Customization

### Changing Pane Sizes

The default layout is:
- Left pane (Claude): 50%
- Top-right pane (Terminal): 25%
- Bottom-right pane (Git): 25%

To modify, edit the `ai()` function in `~/.zshrc` or `~/.bashrc`:

```bash
ai() {
  # ... (earlier code remains the same)

  # For 60/20/20 split instead of 50/25/25:
  # Modify the split-window commands:

  # Split at 60% instead of 50%
  tmux split-window -h -p 40 -t "$session_name:1" -c "$start_dir"

  # Bottom pane size (of the right side)
  tmux split-window -v -p 50 -t "$session_name:1.2" -c "$start_dir"

  # ... (rest of function)
}
```

**Note:** `-p 40` means "make the new pane 40%", leaving 60% for the first pane.

### Alternative Layouts

#### 2-Pane Layout (Claude + Terminal)

```bash
ai2() {
  local session_name="ai-coding-2pane"
  local start_dir="$PWD"

  tmux kill-session -t "$session_name" 2>/dev/null
  tmux new-session -d -s "$session_name" -n "workspace" -c "$start_dir"

  # Just one split
  tmux split-window -h -t "$session_name:1" -c "$start_dir"

  tmux select-pane -t "$session_name:1.1" -T "AI CLI"
  tmux select-pane -t "$session_name:1.2" -T "Terminal"

  tmux send-keys -t "$session_name:1.1" "claude --dangerously-skip-permissions" C-m
  tmux select-pane -t "$session_name:1.2"
  tmux attach -t "$session_name"
}
```

#### 4-Pane Layout (Quad)

```bash
ai4() {
  local session_name="ai-coding-4pane"
  local start_dir="$PWD"

  tmux kill-session -t "$session_name" 2>/dev/null
  tmux new-session -d -s "$session_name" -n "workspace" -c "$start_dir"

  # Split into 4 equal panes
  tmux split-window -h -t "$session_name:1" -c "$start_dir"
  tmux split-window -v -t "$session_name:1.1" -c "$start_dir"
  tmux split-window -v -t "$session_name:1.2" -c "$start_dir"

  tmux select-pane -t "$session_name:1.1" -T "AI CLI"
  tmux select-pane -t "$session_name:1.2" -T "Terminal"
  tmux select-pane -t "$session_name:1.3" -T "Git"
  tmux select-pane -t "$session_name:1.4" -T "Logs"

  tmux send-keys -t "$session_name:1.1" "claude --dangerously-skip-permissions" C-m
  tmux send-keys -t "$session_name:1.3" "lazygit" C-m

  tmux select-pane -t "$session_name:1.2"
  tmux attach -t "$session_name"
}
```

## Claude CLI Configuration

### Changing Claude Mode

Edit environment variables in your shell config (`~/.zshrc` or `~/.bashrc`):

```bash
# Dangerous mode (skip all permissions)
export AI_CLAUDE_MODE="dangerous"

# Safe mode (prompt for permissions)
export AI_CLAUDE_MODE="safe"

# Custom flags
export AI_CLAUDE_MODE="--model sonnet --verbose"
```

Then reload: `source ~/.zshrc`

### Per-Session Override

```bash
# One-time dangerous mode
AI_CLAUDE_MODE="dangerous" ai

# One-time safe mode
AI_CLAUDE_MODE="safe" ai

# Custom flags for this session
AI_CLAUDE_MODE="--model opus" ai
```

## Keybindings

### Default Keybindings

All tmux commands start with the **prefix key**: `Ctrl+b`

| Keybinding | Action |
|------------|--------|
| `Ctrl+b` then `h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+b` then `\|` | Split vertically |
| `Ctrl+b` then `-` | Split horizontally |
| `Ctrl+b` then `r` | Reload config |
| `Ctrl+b` then `S` | Sync panes |
| `Ctrl+b` then `d` | Detach |
| `Ctrl+b` then `[` | Enter copy mode |
| `Ctrl+b` then `?` | Show all keybindings |

### Changing the Prefix Key

To use `Ctrl+a` instead of `Ctrl+b`, edit `~/.tmux.conf`:

```bash
# Unbind default prefix
unbind C-b

# Set new prefix
set -g prefix C-a

# Ensure Ctrl+a can be sent to applications
bind C-a send-prefix
```

### Custom Keybindings

Add to `~/.tmux.conf`:

```bash
# Easier pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Quick window switching
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3

# Create new window in current directory
bind c new-window -c "#{pane_current_path}"

# Toggle mouse on/off
bind m set -g mouse on \; display 'Mouse: ON'
bind M set -g mouse off \; display 'Mouse: OFF'

# Clear pane history
bind C-k clear-history
```

The `-r` flag allows repeating without prefix.
The `-n` flag means no prefix required.

## Adding Custom Panes

### Adding a Logs Pane

Modify the `ai()` function to add a 4th pane:

```bash
ai() {
  # ... (existing setup code)

  # After creating the 3 existing panes, add a 4th:
  tmux split-window -v -t "$session_name:1.3" -c "$start_dir"
  tmux select-pane -t "$session_name:1.4" -T "Logs"

  # Start a log viewer
  tmux send-keys -t "$session_name:1.4" "tail -f /var/log/syslog" C-m

  # ... (rest of function)
}
```

### Adding a REPL Pane

For Python development:

```bash
# Add another pane for Python REPL
tmux split-window -v -t "$session_name:1.2" -c "$start_dir"
tmux select-pane -t "$session_name:1.3" -T "Python REPL"
tmux send-keys -t "$session_name:1.3" "python3" C-m
```

### Adding a Server Pane

For web development:

```bash
# Add pane for dev server
tmux split-window -v -t "$session_name:1.2" -c "$start_dir"
tmux select-pane -t "$session_name:1.3" -T "Dev Server"
tmux send-keys -t "$session_name:1.3" "npm run dev" C-m
```

## Shell Integration

### Changing Session Name

Edit environment variable:

```bash
# In ~/.zshrc or ~/.bashrc
export AI_SESSION_NAME="my-project"
```

### Per-Project Workspaces

Create project-specific functions:

```bash
# Frontend project
ai-frontend() {
  export AI_SESSION_NAME="frontend-dev"
  cd ~/projects/frontend
  ai
}

# Backend project
ai-backend() {
  export AI_SESSION_NAME="backend-dev"
  cd ~/projects/backend
  ai
}

# Add to ~/.zshrc or ~/.bashrc
```

### Auto-Start on Directory Change

Using zsh hooks:

```bash
# In ~/.zshrc
chpwd() {
  # Auto-start AI workspace when entering project directory
  if [[ "$PWD" == "$HOME/projects/myapp" ]]; then
    if ! tmux has-session -t ai-coding 2>/dev/null; then
      ai
    fi
  fi
}
```

## Advanced Customization

### Custom Tmux Status Line

Install powerline or tmux-powerline:

```bash
# Add to ~/.tmux.conf
set -g @plugin 'erikw/tmux-powerline'

# Then install TPM plugins:
# Ctrl+b then I
```

### Tmux Session Management

Add tmuxinator for predefined sessions:

```bash
# Install tmuxinator
gem install tmuxinator

# Create a project template
tmuxinator new ai-project

# Edit the template to match your ai() function
# Start with: tmuxinator start ai-project
```

### Vim Integration

If using vim/neovim in the terminal pane:

```bash
# Add to ~/.tmux.conf for seamless vim/tmux navigation
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
```

### Copy Mode Enhancements

```bash
# Add to ~/.tmux.conf
# Use v to begin selection (like vim)
bind -T copy-mode-vi v send -X begin-selection

# Use y to yank (copy)
bind -T copy-mode-vi y send -X copy-selection-and-cancel

# Use V for line selection
bind -T copy-mode-vi V send -X select-line

# Use r for rectangle selection
bind -T copy-mode-vi r send -X rectangle-toggle
```

### Environment-Specific Configurations

Load different configs based on environment:

```bash
# Add to ~/.tmux.conf
if-shell '[ "$SSH_CONNECTION" != "" ]' \
  'set -g status-bg colour196' \
  'set -g status-bg colour237'

# Red status bar for SSH sessions, grey for local
```

## Reloading Configuration

After making changes:

```bash
# Reload tmux config
tmux source ~/.tmux.conf

# Reload shell config
source ~/.zshrc  # or ~/.bashrc

# Or restart tmux entirely
tmux kill-server
ai
```

---

**Pro Tip:** Keep your customizations in a separate file:

```bash
# In ~/.tmux.conf
source-file ~/.tmux.conf.local

# Put your custom settings in ~/.tmux.conf.local
# This way, updates to the base config won't overwrite your changes
```

Need more ideas? Check out:
- [awesome-tmux](https://github.com/rothgar/awesome-tmux) - Curated list of tmux plugins and configs
- [tmux plugins](https://github.com/tmux-plugins) - Official tmux plugins
