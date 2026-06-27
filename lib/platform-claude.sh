#!/usr/bin/env bash
# platform-claude.sh — install/update the supensour plugin for Claude Code.
# Claude registers a marketplace from a git URL, then installs PLUGIN@MARKETPLACE.


claude_install() {
  claude plugin marketplace add "$REPO_URL"           || die "claude: marketplace add failed"
  claude plugin install "${PLUGIN}@${MARKETPLACE}"    || die "claude: install failed"
  ok "claude: installed ${PLUGIN}@${MARKETPLACE}"
}

claude_update() {
  claude plugin marketplace update "$MARKETPLACE"      || die "claude: marketplace update failed"
  claude plugin update "${PLUGIN}@${MARKETPLACE}"      || die "claude: update failed"
  ok "claude: updated ${PLUGIN}@${MARKETPLACE}"
  reload_reminder claude
}
