#!/usr/bin/env bash
# ========================================
# Platform Detection Script
# ========================================
# Detects the operating system and provides package manager abstraction

detect_platform() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    echo "wsl"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  elif [[ -f /etc/redhat-release ]]; then
    echo "redhat"
  elif [[ -f /etc/arch-release ]]; then
    echo "arch"
  else
    echo "unknown"
  fi
}

install_package() {
  local package=$1
  local platform=$(detect_platform)

  echo "Installing $package on $platform..."

  case "$platform" in
    macos)
      if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew not found. Install from https://brew.sh"
        return 1
      fi
      brew install "$package"
      ;;
    debian|wsl)
      sudo apt-get update
      sudo apt-get install -y "$package"
      ;;
    redhat)
      sudo yum install -y "$package"
      ;;
    arch)
      sudo pacman -S --noconfirm "$package"
      ;;
    *)
      echo "Error: Unsupported platform"
      return 1
      ;;
  esac
}

check_package_manager() {
  local platform=$(detect_platform)

  case "$platform" in
    macos)
      if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found"
        echo "Install Homebrew from: https://brew.sh"
        return 1
      fi
      echo "✓ Homebrew found"
      ;;
    debian|wsl)
      if ! command -v apt-get &> /dev/null; then
        echo "❌ apt-get not found"
        return 1
      fi
      echo "✓ apt-get found"
      ;;
    redhat)
      if ! command -v yum &> /dev/null && ! command -v dnf &> /dev/null; then
        echo "❌ yum/dnf not found"
        return 1
      fi
      echo "✓ yum/dnf found"
      ;;
    arch)
      if ! command -v pacman &> /dev/null; then
        echo "❌ pacman not found"
        return 1
      fi
      echo "✓ pacman found"
      ;;
    *)
      echo "❌ Unsupported platform: $platform"
      return 1
      ;;
  esac
}
