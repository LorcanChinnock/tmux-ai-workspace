# Uninstallation Guide

This guide covers both automated and manual methods for removing tmux-ai-workspace from your system.

## Table of Contents

- [Automated Uninstall (Recommended)](#automated-uninstall-recommended)
- [Manual Uninstall](#manual-uninstall)
- [What Gets Removed](#what-gets-removed)
- [Backup Files](#backup-files)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Automated Uninstall (Recommended)

### Using the Uninstall Script

The easiest way to remove tmux-ai-workspace is using the provided uninstaller:

```bash
cd tmux-ai-workspace
./uninstall.sh
```

### What the Script Does

The uninstaller will:

1. **Remove shell configuration** - Removes the `ai()` function and aliases from `~/.zshrc` and/or `~/.bashrc`
2. **Create backups** - Automatically backs up all modified files with timestamps
3. **Prompt for optional removals**:
   - `~/.tmux.conf` - Your tmux configuration (may contain non-tmux-ai-workspace customizations)
   - `~/.tmux/plugins/tpm` - Tmux Plugin Manager (may be used by other configs)
4. **Offer restoration** - Optionally restore from the most recent backup files

### Interactive Prompts

You'll be asked several questions during uninstallation:

```bash
Continue? [y/N]:                    # Confirm uninstall
Remove ~/.tmux.conf? [y/N]:         # Remove tmux config (optional)
Restore backups? [y/N]:             # Restore from latest backups (optional)
Remove TPM? [y/N]:                  # Remove Tmux Plugin Manager (optional)
```

**Recommendation**: Answer **N** to removing `~/.tmux.conf` if you've made custom modifications beyond tmux-ai-workspace.

### After Running the Script

Reload your shell to apply changes:

```bash
# For zsh users
source ~/.zshrc

# For bash users
source ~/.bashrc

# Or simply close and reopen your terminal
```

Verify the `ai` command is gone:

```bash
which ai
# Should output: ai not found
```

---

## Manual Uninstall

If you prefer to uninstall manually or the script fails, follow these steps:

### Step 1: Backup Your Configuration Files

**Always create backups before making changes:**

```bash
# Backup shell configs
cp ~/.zshrc ~/.zshrc.backup_manual_$(date +%Y%m%d_%H%M%S)
cp ~/.bashrc ~/.bashrc.backup_manual_$(date +%Y%m%d_%H%M%S)

# Backup tmux config
cp ~/.tmux.conf ~/.tmux.conf.backup_manual_$(date +%Y%m%d_%H%M%S)
```

### Step 2: Remove Shell Function from Zsh

Edit `~/.zshrc` and remove the entire tmux-ai-workspace section:

```bash
vim ~/.zshrc  # or nano, emacs, etc.
```

**Delete these lines:**

```bash
# ========================================
# tmux-ai-workspace
# ========================================
export AI_CLAUDE_MODE="dangerous"  # (or "safe" or custom)

ai() {
  # ... entire function body ...
}

# Tmux helper aliases
alias ta='tmux attach'
alias tl='tmux ls'
alias tk='tmux kill-session -t'
```

**Using sed (advanced):**

```bash
# Remove the section between markers
sed -i.bak '/# ========================================/,/alias tk=/d' ~/.zshrc

# If the markers aren't present, manually remove lines
sed -i.bak '/^ai()/,/^}/d' ~/.zshrc
sed -i.bak '/^alias ta=/d' ~/.zshrc
sed -i.bak '/^alias tl=/d' ~/.zshrc
sed -i.bak '/^alias tk=/d' ~/.zshrc
sed -i.bak '/^export AI_CLAUDE_MODE=/d' ~/.zshrc
```

### Step 3: Remove Shell Function from Bash

Edit `~/.bashrc` and remove the same section:

```bash
vim ~/.bashrc
```

**Or using sed:**

```bash
sed -i.bak '/# ========================================/,/alias tk=/d' ~/.bashrc
sed -i.bak '/^ai()/,/^}/d' ~/.bashrc
sed -i.bak '/^alias ta=/d' ~/.bashrc
sed -i.bak '/^alias tl=/d' ~/.bashrc
sed -i.bak '/^alias tk=/d' ~/.bashrc
sed -i.bak '/^export AI_CLAUDE_MODE=/d' ~/.bashrc
```

### Step 4: Reload Shell Configuration

```bash
# For zsh
source ~/.zshrc

# For bash
source ~/.bashrc
```

### Step 5: Remove Tmux Configuration (Optional)

**⚠️ Warning**: Only do this if you don't have custom tmux configurations you want to keep.

```bash
# Option A: Remove completely
rm ~/.tmux.conf

# Option B: Keep a backup and remove
mv ~/.tmux.conf ~/.tmux.conf.removed_$(date +%Y%m%d_%H%M%S)
```

If you have custom tmux configurations, manually edit `~/.tmux.conf` to remove only tmux-ai-workspace-specific settings.

### Step 6: Remove TPM (Optional)

**⚠️ Warning**: Only remove if you don't use tmux plugins outside of tmux-ai-workspace.

```bash
# Option A: Remove completely
rm -rf ~/.tmux/plugins/tpm

# Option B: Keep a backup
mv ~/.tmux/plugins/tpm ~/.tmux/plugins/tpm.backup_$(date +%Y%m%d_%H%M%S)
```

### Step 7: Kill Existing Tmux Sessions

If you have active tmux-ai-workspace sessions:

```bash
# List all sessions
tmux ls

# Kill a specific session
tmux kill-session -t AI-projectname

# Or kill all sessions (use with caution!)
tmux kill-server
```

### Step 8: Remove Installation Directory (Optional)

If you cloned the repository for installation:

```bash
cd ~
rm -rf tmux-ai-workspace
```

---

## What Gets Removed

### Always Removed
- ✅ `ai()` function from shell config
- ✅ Environment variable `AI_CLAUDE_MODE`
- ✅ Shell aliases: `ta`, `tl`, `tk`

### Optionally Removed (with prompts)
- ⚠️ `~/.tmux.conf` - Your tmux configuration file
- ⚠️ `~/.tmux/plugins/tpm` - Tmux Plugin Manager
- ⚠️ `~/tmux-ai-workspace/` - The cloned repository (manual removal)

### Never Removed (Intentionally Preserved)
- ✅ `tmux` - System tmux installation
- ✅ `lazygit` - If installed, remains on system
- ✅ `claude` - Claude CLI installation
- ✅ Backup files (`.backup_*` files)

---

## Backup Files

### Backup File Naming

All backups use timestamp format:

```
~/.zshrc.backup_20260206_143022
~/.bashrc.backup_20260206_143022
~/.tmux.conf.backup_20260206_143022
```

### Locating Backups

```bash
# List all backup files
ls -lah ~/.*.backup_*

# List by most recent
ls -lth ~/.*.backup_* | head -5
```

### Restoring from Backup

**Restore specific file:**

```bash
# Restore zshrc from backup
cp ~/.zshrc.backup_20260206_143022 ~/.zshrc
source ~/.zshrc

# Restore bashrc from backup
cp ~/.bashrc.backup_20260206_143022 ~/.bashrc
source ~/.bashrc

# Restore tmux config from backup
cp ~/.tmux.conf.backup_20260206_143022 ~/.tmux.conf
tmux source ~/.tmux.conf  # If tmux is running
```

**Find the most recent backup:**

```bash
# Most recent zshrc backup
ls -t ~/.zshrc.backup_* | head -n1

# Most recent tmux.conf backup
ls -t ~/.tmux.conf.backup_* | head -n1
```

### Cleaning Up Old Backups

After verifying uninstallation worked correctly:

```bash
# Remove all tmux-ai-workspace backups older than 30 days
find ~ -maxdepth 1 -name "*.backup_*" -mtime +30 -exec rm {} \;

# Or manually review and delete
ls -lah ~/.*.backup_*
rm ~/.zshrc.backup_20260101_120000  # Example: delete specific old backup
```

---

## Verification

### Verify Complete Removal

**1. Check shell function is removed:**

```bash
# Should return: ai: command not found
ai

# Should return: (nothing) or "not found"
which ai

# Should return: (nothing)
type ai
```

**2. Check aliases are removed:**

```bash
# These should show default behavior or "not found"
type ta
type tl
type tk
```

**3. Verify shell config is clean:**

```bash
# Should return no results
grep -n "tmux-ai-workspace" ~/.zshrc
grep -n "ai()" ~/.zshrc

# For bash users
grep -n "tmux-ai-workspace" ~/.bashrc
grep -n "ai()" ~/.bashrc
```

**4. Check environment variables:**

```bash
# Should return: (nothing)
echo $AI_CLAUDE_MODE
```

**5. Verify tmux config (if removed):**

```bash
# Should show: No such file or directory (if removed)
ls -la ~/.tmux.conf

# Or if kept, verify no tmux-ai-workspace specific settings
grep -n "tmux-ai-workspace" ~/.tmux.conf
```

**6. Verify TPM (if removed):**

```bash
# Should show: No such file or directory (if removed)
ls -la ~/.tmux/plugins/tpm
```

### Test Shell Reloading

```bash
# Close terminal and reopen
# Then verify:
ai  # Should not work
echo $AI_CLAUDE_MODE  # Should be empty
```

---

## Troubleshooting

### "ai" Command Still Works After Uninstall

**Cause**: Shell config wasn't reloaded.

**Solution**:
```bash
# Reload your shell config
source ~/.zshrc  # or ~/.bashrc

# Or restart your terminal completely
exit
# Then open a new terminal window
```

If it still persists:
```bash
# Check if function exists in current shell
type ai

# Check if it's in your config file
grep "ai()" ~/.zshrc ~/.bashrc

# Manually remove it if found
```

### "Permission Denied" When Running Uninstall Script

**Cause**: Script doesn't have execute permissions.

**Solution**:
```bash
# Make script executable
chmod +x uninstall.sh

# Then run it
./uninstall.sh
```

### Uninstall Script Not Found

**Cause**: You're not in the tmux-ai-workspace directory.

**Solution**:
```bash
# Find the directory
find ~ -type d -name "tmux-ai-workspace" 2>/dev/null

# Navigate to it
cd ~/tmux-ai-workspace  # Adjust path as needed

# Run uninstaller
./uninstall.sh

# Or use absolute path
bash ~/path/to/tmux-ai-workspace/uninstall.sh
```

### Can't Find Repository (Used One-Line Install)

**Cause**: One-line installer doesn't clone the repository permanently.

**Solution**: Use manual uninstall method (see [Manual Uninstall](#manual-uninstall) section above).

Or download the uninstaller directly:

```bash
curl -fsSL https://raw.githubusercontent.com/LorcanChinnock/tmux-ai-workspace/main/uninstall.sh | bash
```

### Lost Work Due to Accidental Removal

**Cause**: Removed `.tmux.conf` that had custom configurations.

**Solution**:
```bash
# Find your backup
ls -lt ~/.tmux.conf.backup_* | head -n1

# Restore it
cp ~/.tmux.conf.backup_20260206_143022 ~/.tmux.conf

# Reload tmux
tmux source ~/.tmux.conf
```

### TPM Plugins Stopped Working

**Cause**: Accidentally removed TPM while other configurations depend on it.

**Solution**:
```bash
# Reinstall TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Then in tmux, press: Ctrl+b then I (capital i)
```

### Tmux Config Errors After Partial Removal

**Cause**: Partially edited `.tmux.conf` has syntax errors.

**Solution**:
```bash
# Test your tmux config
tmux source ~/.tmux.conf

# If errors occur, restore from backup
cp ~/.tmux.conf.backup_[latest] ~/.tmux.conf

# Or start fresh
rm ~/.tmux.conf
# Then customize as needed
```

### Shell Performance Degraded After Uninstall

**Cause**: Multiple backup/temp files created by sed.

**Solution**:
```bash
# Find and remove sed temp files
find ~ -maxdepth 1 -name "*.tmp" -delete
find ~ -maxdepth 1 -name "*.bak" -ls

# Review and delete manually if needed
rm ~/.zshrc.tmp ~/.bashrc.tmp
```

---

## Need Help?

If you encounter issues not covered here:

1. **Check existing backups**: `ls -lah ~/.*.backup_*`
2. **Review troubleshooting**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. **Restore from backup**: Copy your most recent backup file
4. **Manual cleanup**: Follow the [Manual Uninstall](#manual-uninstall) steps carefully
5. **Report an issue**: https://github.com/LorcanChinnock/tmux-ai-workspace/issues

---

**Remember**: All configuration files are backed up before modification. You can always restore to your previous state by copying from backup files.
