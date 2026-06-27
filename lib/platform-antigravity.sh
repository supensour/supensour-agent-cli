#!/usr/bin/env bash
# platform-antigravity.sh — install/update the supensour plugin for Antigravity CLI (agy).
# Antigravity has no github marketplace: it installs from a local path, so we
# install from the cached clone. Reinstalling picks up pulled changes.

antigravity_install() {
  ensure_cache
  agy plugin install "$CACHE_DIR"                      || die "antigravity: install failed"
  ok "antigravity: installed from $CACHE_DIR"
}

antigravity_update() {
  ensure_cache
  agy plugin install "$CACHE_DIR"                      || die "antigravity: reinstall failed"
  ok "antigravity: updated from $CACHE_DIR"
  reload_reminder antigravity
}
