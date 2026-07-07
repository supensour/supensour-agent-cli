#!/usr/bin/env bash
# install.sh — put `supensour` on PATH and clone the skill cache.
#
#   1. Copy this CLI (bin/ + lib/) → ~/.supensour/supensour-agent-cli
#   2. Symlink ~/.local/bin/supensour → ~/.supensour/supensour-agent-cli/bin/supensour
#   3. Ensure ~/.local/bin is on PATH (idempotent shell-rc append)
#   4. Clone supensour-agent → ~/.supensour/supensour-agent
#
# Re-runnable: safe to run again to refresh the installed CLI.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLI_HOME="$HOME/.supensour/supensour-agent-cli"
BIN_DIR="$HOME/.local/bin"
BIN_LINK="$BIN_DIR/supensour"

log() { printf '%s\n' "$*" >&2; }
die() { printf '✖ %s\n' "$*" >&2; exit 1; }

# 1. Copy CLI into a stable home.
log "Installing CLI → $CLI_HOME"
mkdir -p "$CLI_HOME"
cp -R "$SRC_DIR/bin" "$SRC_DIR/lib" "$CLI_HOME/"
chmod +x "$CLI_HOME/bin/supensour"

# 2. Symlink onto PATH.
mkdir -p "$BIN_DIR"
ln -sf "$CLI_HOME/bin/supensour" "$BIN_LINK"
log "Linked $BIN_LINK"

# 3. Ensure ~/.local/bin is on PATH (idempotent).
ensure_path() {
  local rc="$1" line='export PATH="$HOME/.local/bin:$PATH"'
  [ -f "$rc" ] || return 0
  grep -qF '.local/bin' "$rc" && return 0
  printf '\n# supensour CLI\n%s\n' "$line" >> "$rc"
  log "Added ~/.local/bin to PATH in $rc"
}
case "$(basename "${SHELL:-}")" in
  zsh)  ensure_path "$HOME/.zshrc" ;;
  bash) ensure_path "$HOME/.bashrc" ;;
  *)    ensure_path "$HOME/.profile" ;;
esac

# 4. Fetch the skill cache (used by antigravity; canonical source).
# shellcheck source=lib/common.sh
. "$SRC_DIR/lib/common.sh"
ensure_cache

cat >&2 <<EOF

✓ Done. Restart your shell (or: export PATH="\$HOME/.local/bin:\$PATH").
  Then run:  supensour plugins install <claude|copilot|antigravity|cursor>
  Or all:    supensour plugins install
  Update CLI later:  supensour update
EOF
