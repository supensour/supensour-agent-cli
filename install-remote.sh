#!/usr/bin/env bash
# install-remote.sh — bootstrap: fetch supensour-agent-cli, then run install.sh
#
# Intended usage (script is not saved to disk):
#   curl -fsSL https://raw.githubusercontent.com/supensour/supensour-agent-cli/master/install-remote.sh | bash
set -euo pipefail

CLI_REPO_URL="https://github.com/supensour/supensour-agent-cli"
CLI_HOME="${SUPENSOUR_CLI_HOME:-$HOME/.supensour/supensour-agent-cli}"
BRANCH="${SUPENSOUR_CLI_BRANCH:-master}"
ARCHIVE_URL="${CLI_REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz"

log() { printf '%s\n' "$*" >&2; }
die() { printf '✖ %s\n' "$*" >&2; exit 1; }

fetch_via_git() {
  if [ -d "$CLI_HOME/.git" ]; then
    log "Updating $CLI_HOME"
    git -C "$CLI_HOME" pull --ff-only || die "git pull failed in $CLI_HOME"
    return
  fi

  if [ -e "$CLI_HOME" ]; then
    log "Replacing existing install: $CLI_HOME"
    rm -rf "$CLI_HOME"
  fi

  log "Cloning $CLI_REPO_URL → $CLI_HOME"
  mkdir -p "$(dirname "$CLI_HOME")"
  git clone --branch "$BRANCH" "$CLI_REPO_URL" "$CLI_HOME" \
    || die "git clone failed"
}

fetch_via_archive() {
  command -v curl >/dev/null 2>&1 || die "curl is required but not on PATH."
  command -v tar >/dev/null 2>&1 || die "tar is required but not on PATH."

  local tmp extracted
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  log "Downloading $ARCHIVE_URL"
  curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$tmp" || die "archive download or extract failed"

  extracted="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -1)"
  [ -n "$extracted" ] || die "archive extraction failed — no top-level directory found"

  if [ -e "$CLI_HOME" ]; then
    log "Replacing existing install: $CLI_HOME"
    rm -rf "$CLI_HOME"
  fi

  mkdir -p "$(dirname "$CLI_HOME")"
  mv "$extracted" "$CLI_HOME"
  log "Installed CLI → $CLI_HOME"
}

if command -v git >/dev/null 2>&1; then
  fetch_via_git
else
  fetch_via_archive
fi

exec bash "$CLI_HOME/install.sh"
