#!/usr/bin/env bash
# common.sh — shared constants and helpers for the supensour CLI.
# Sourced by bin/supensour and every lib/platform-*.sh.
#
# Logging goes to STDERR so STDOUT stays clean.

# --- Identity ---------------------------------------------------------------
# These mirror supensour's .claude-plugin manifests:
#   PLUGIN      = plugin.json      "name"
#   MARKETPLACE = marketplace.json "name"
PLUGIN="supensour"
MARKETPLACE="supensour"
REPO_SLUG="supensour/supensour-agent"
REPO_URL="https://github.com/supensour/supensour-agent"
CACHE_BRANCH="${SUPENSOUR_CACHE_BRANCH:-master}"
CACHE_ARCHIVE_URL="${REPO_URL}/archive/refs/heads/${CACHE_BRANCH}.tar.gz"

# Canonical local clone. Antigravity installs from this path (it has no
# github marketplace); also serves as the cursor pull target.
CACHE_DIR="$HOME/.supensour/supensour-agent"

# Platforms handled by the CLI, in run-all order.
PLATFORMS="claude copilot antigravity cursor"

export PLUGIN MARKETPLACE REPO_SLUG REPO_URL CACHE_DIR PLATFORMS

# --- Logging ----------------------------------------------------------------
log()  { printf '%s\n' "$*" >&2; }
warn() { printf '⚠ %s\n' "$*" >&2; }
die()  { printf '✖ %s\n' "$*" >&2; exit 1; }
ok()   { printf '✓ %s\n' "$*" >&2; }

# --- CLI presence -----------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

# platform → required CLI binary.
cli_for() {
  case "$1" in
    claude)      printf 'claude'  ;;
    copilot)     printf 'copilot' ;;
    antigravity) printf 'agy'     ;;
    cursor)      printf 'cursor'  ;;
    *)           return 1         ;;
  esac
}

# --- Cache ------------------------------------------------------------------
# cache_fetch_via_git — clone or pull the agent repo into CACHE_DIR.
cache_fetch_via_git() {
  if [ -d "$CACHE_DIR/.git" ]; then
    log "Updating cache: $CACHE_DIR"
    git -C "$CACHE_DIR" pull --ff-only || die "git pull failed in $CACHE_DIR"
    return
  fi

  if [ -e "$CACHE_DIR" ]; then
    log "Replacing existing cache: $CACHE_DIR"
    rm -rf "$CACHE_DIR"
  fi

  log "Cloning $REPO_URL → $CACHE_DIR"
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone --branch "$CACHE_BRANCH" "$REPO_URL" "$CACHE_DIR" || die "git clone failed"
}

# cache_fetch_via_archive — download the agent repo tarball into CACHE_DIR.
cache_fetch_via_archive() {
  have curl || die "curl is required but not on PATH."
  have tar  || die "tar is required but not on PATH."

  local tmp extracted
  tmp="$(mktemp -d)"

  log "Downloading $CACHE_ARCHIVE_URL"
  if ! curl -fsSL "$CACHE_ARCHIVE_URL" | tar -xz -C "$tmp"; then
    rm -rf "$tmp"
    die "archive download or extract failed"
  fi

  extracted="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -1)"
  if [ -z "$extracted" ]; then
    rm -rf "$tmp"
    die "archive extraction failed — no top-level directory found"
  fi

  if [ -e "$CACHE_DIR" ]; then
    log "Replacing existing cache: $CACHE_DIR"
    rm -rf "$CACHE_DIR"
  fi

  mkdir -p "$(dirname "$CACHE_DIR")"
  mv "$extracted" "$CACHE_DIR"
  rm -rf "$tmp"
  log "Cache ready: $CACHE_DIR"
}

# ensure_cache — refresh the agent repo at CACHE_DIR (git or archive fallback).
ensure_cache() {
  if have git; then
    cache_fetch_via_git
  else
    cache_fetch_via_archive
  fi
}

# --- Post-update reminder ---------------------------------------------------
# reload_reminder <platform> — plugins/skills load at session start; a running
# session must be restarted to pick up changes. The CLI can't reload it.
reload_reminder() {
  log "↻ Restart your $1 session to load the updated plugin and skills."
}

# --- Dispatch ---------------------------------------------------------------
# dispatch <platform> <install|update> [strict]
#   Verifies the platform CLI is on PATH, then calls <platform>_<action>.
#   strict=1 → die if the CLI is missing (explicit single-platform call).
#   strict unset → skip with a notice (run-all loop).
dispatch() {
  local platform="$1" action="$2" strict="${3:-}"
  local bin; bin="$(cli_for "$platform")" || die "unknown platform: $platform"
  if ! have "$bin"; then
    if [ -n "$strict" ]; then
      die "'$bin' not found on PATH — cannot $action $platform."
    fi
    log "• skip $platform — '$bin' not on PATH"
    return 0
  fi
  "${platform}_${action}"
}

# run_all <install|update> — dispatch every platform, skipping missing CLIs.
run_all() {
  local action="$1" p
  for p in $PLATFORMS; do
    dispatch "$p" "$action"
  done
}
