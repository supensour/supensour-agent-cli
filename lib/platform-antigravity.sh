#!/usr/bin/env bash
# platform-antigravity.sh — install/update the supensour plugin for Antigravity CLI (agy).
# Antigravity has no github marketplace: it installs from a local path, so we
# install from the cached clone. Reinstalling picks up pulled changes.
#
# We install from a `.git`-free staged copy (see stage_plugin_dir) and clear any
# stale install first: `agy plugin install` copies the source dir verbatim, and
# git's read-only loose objects (mode 0444) under `.git/objects` make a re-install
# fail with "permission denied" when it overwrites a previous install.

# _antigravity_reset_dest — remove a prior install so agy copies fresh. Older CLI
# versions installed `.git` into the plugin dir; those read-only objects block
# overwrite (EACCES). Best-effort: unlock perms, then remove.
_antigravity_reset_dest() {
  local dest="$HOME/.gemini/config/plugins/$PLUGIN"
  [ -d "$dest" ] || return 0
  chmod -R u+w "$dest" 2>/dev/null || true
  rm -rf "$dest" 2>/dev/null \
    || warn "Could not clear old Antigravity install at $dest — remove it manually: rm -rf '$dest'"
}

# _antigravity_apply <verb> — shared install/reinstall from a clean staged copy.
_antigravity_apply() {
  local verb="$1" staged tmp
  ensure_cache
  _antigravity_reset_dest
  staged="$(stage_plugin_dir)"; tmp="$(dirname "$staged")"
  if ! agy plugin install "$staged"; then
    rm -rf "$tmp"
    die "antigravity: $verb failed"
  fi
  rm -rf "$tmp"
  ok "antigravity: $verb from clean copy (no .git)"
}

antigravity_install() { _antigravity_apply installed; }

antigravity_update() {
  _antigravity_apply updated
  reload_reminder antigravity
}
