#!/usr/bin/env bash
# install.sh — put `supensour` on PATH and clone the skill cache.
#
#   1. Copy this CLI (bin/ + lib/) → ~/.supensour/cli
#   2. Symlink ~/.local/bin/supensour → ~/.supensour/cli/bin/supensour
#   3. Ensure ~/.local/bin is on PATH (idempotent shell-rc append)
#   4. Clone supensour-agent → ~/.supensour/supensour-agent
#
# Re-runnable: safe to run again to refresh the installed CLI.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO_URL="https://github.com/supensour/supensour-agent"
CLI_HOME="$HOME/.supensour/cli"
CACHE_DIR="$HOME/.supensour/supensour-agent"
BIN_DIR="$HOME/.local/bin"
BIN_LINK="$BIN_DIR/supensour"

log() { printf '%s\n' "$*" >&2; }
die() { printf '✖ %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required but not on PATH."

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

# 4. Clone the skill cache (used by antigravity; canonical source).
if [ -d "$CACHE_DIR/.git" ]; then
  log "Cache exists: $CACHE_DIR (run 'supensour init' to refresh)"
else
  log "Cloning $REPO_URL → $CACHE_DIR"
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone "$REPO_URL" "$CACHE_DIR"
fi

cat >&2 <<EOF

✓ Done. Restart your shell (or: export PATH="\$HOME/.local/bin:\$PATH").
  Then run:  supensour install <claude|copilot|antigravity|cursor>
  Or all:    supensour install
EOF
