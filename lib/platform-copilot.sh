#!/usr/bin/env bash
# platform-copilot.sh — install/update the supensour plugin for GitHub Copilot CLI.
# Copilot reads the same .claude-plugin/marketplace.json the repo already ships.
# Marketplace add takes OWNER/REPO; install takes PLUGIN@MARKETPLACE.

copilot_install() {
  copilot plugin marketplace add "$REPO_SLUG"          || die "copilot: marketplace add failed"
  copilot plugin install "${PLUGIN}@${MARKETPLACE}"    || die "copilot: install failed"
  ok "copilot: installed ${PLUGIN}@${MARKETPLACE}"
}

copilot_update() {
  copilot plugin marketplace update "$MARKETPLACE"     || die "copilot: marketplace update failed"
  copilot plugin update "${PLUGIN}@${MARKETPLACE}"     || die "copilot: update failed"
  ok "copilot: updated ${PLUGIN}@${MARKETPLACE}"
  reload_reminder copilot
}
