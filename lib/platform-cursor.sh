#!/usr/bin/env bash
# platform-cursor.sh — Cursor has no plugin-install CLI. We print the in-chat
# guide. Update also refreshes the cache so a local-symlink workflow stays current.

cursor_install() {
  cat >&2 <<EOF
Cursor has no install CLI. In the Cursor chat box, run:

  /add-plugin $REPO_URL

Then enable it under Customize → Plugins.
EOF
}

cursor_update() {
  ensure_cache
  cat >&2 <<EOF
Cursor: cache refreshed. In the Cursor chat box, re-run:

  /add-plugin $REPO_URL

If changes don't appear (Git can pin an old commit), remove the plugin in
Customize → Plugins and /add-plugin it again.
EOF
}
