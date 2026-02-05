#!/usr/bin/env bash
# ========================================
# AI Coding Workspace Function
# ========================================
# Creates a tmux session optimized for AI-assisted development
# Works in both bash and zsh

# Configuration variables (customizable)
CLAUDE_MODE="${AI_CLAUDE_MODE:-dangerous}"
START_DIR="${AI_START_DIR:-$PWD}"

ai() {
  local start_dir="$PWD"
  # Create dynamic session name: "AI folder-name"
  local folder_name=$(basename "$start_dir")
  # Clean folder name: replace spaces and special chars with hyphens for tmux compatibility
  folder_name=$(echo "$folder_name" | tr ' ' '-' | tr -cd '[:alnum:]-_')
  local session_name="AI-${folder_name}"

  # Check if tmux is installed
  if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed."
    echo "Install with:"
    echo "  macOS: brew install tmux"
    echo "  Ubuntu/Debian: sudo apt-get install tmux"
    echo "  Fedora/RHEL: sudo yum install tmux"
    echo "  Arch: sudo pacman -S tmux"
    return 1
  fi

  # Check if Claude CLI is installed
  if ! command -v claude &> /dev/null; then
    echo "Warning: Claude CLI is not installed."
    echo "The AI pane will be empty. Install Claude CLI from:"
    echo "  https://github.com/anthropics/claude-cli"
    echo ""
    read -p "Continue anyway? [y/N]: " continue_choice
    if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
      return 1
    fi
  fi

  # Check if lazygit is installed
  if ! command -v lazygit &> /dev/null; then
    echo "Warning: lazygit is not installed."
    echo "The Git pane will be empty. Install with:"
    echo "  macOS: brew install lazygit"
    echo "  Ubuntu/Debian: See https://github.com/jesseduffield/lazygit#installation"
    echo ""
  fi

  # Kill existing session if it exists
  tmux kill-session -t "$session_name" 2>/dev/null

  # Create new session with layout in current directory
  echo "Creating AI workspace in: $start_dir"

  # Create session and first window in current directory
  tmux new-session -d -s "$session_name" -n "workspace" -c "$start_dir"

  # Split window vertically (left 50%, right 50%) in current directory
  tmux split-window -h -t "$session_name:1" -c "$start_dir"

  # Split right pane horizontally (top 50%, bottom 50%) in current directory
  tmux split-window -v -t "$session_name:1.2" -c "$start_dir"

  # Set pane titles
  tmux select-pane -t "$session_name:1.1" -T "AI CLI"
  tmux select-pane -t "$session_name:1.2" -T "Terminal"
  tmux select-pane -t "$session_name:1.3" -T "Git"

  # Start Claude CLI in left pane (AI CLI)
  if command -v claude &> /dev/null; then
    if [[ "$CLAUDE_MODE" == "dangerous" ]]; then
      tmux send-keys -t "$session_name:1.1" "claude --dangerously-skip-permissions" C-m
    elif [[ "$CLAUDE_MODE" == "safe" ]]; then
      tmux send-keys -t "$session_name:1.1" "claude" C-m
    else
      # Custom flags
      tmux send-keys -t "$session_name:1.1" "claude $CLAUDE_MODE" C-m
    fi
  fi

  # Start lazygit in bottom-right pane (if installed)
  if command -v lazygit &> /dev/null; then
    tmux send-keys -t "$session_name:1.3" "lazygit" C-m
  fi

  # Select the terminal pane (top-right) as default
  tmux select-pane -t "$session_name:1.2"

  # Attach to the session
  tmux attach -t "$session_name"
}

# Tmux helper aliases
alias ta='tmux attach'
alias tl='tmux ls'
alias tk='tmux kill-session -t'
