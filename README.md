# supensour-agent-cli

Install [supensour-agent](https://github.com/supensour/supensour-agent) skills as a
**plugin** into your AI coding tools — at global (user) scope, from one command.

Supported platforms: **Claude Code**, **GitHub Copilot CLI**, **Antigravity CLI**, **Cursor**.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/supensour/supensour-agent-cli/master/install-remote.sh | bash
```

This puts `supensour` on your PATH (`~/.local/bin`), installs the CLI to
`~/.supensour/supensour-agent-cli`, and clones the skill cache to
`~/.supensour/supensour-agent`. Restart your shell afterward.

<details>
<summary>Manual install (git clone)</summary>

```bash
git clone https://github.com/supensour/supensour-agent-cli
cd supensour-agent-cli
bash install.sh
```
</details>

## Usage

```bash
supensour install [platform]    # install for one platform, or all if omitted
supensour update  [platform]    # update one platform, or all if omitted
supensour init                  # clone/refresh the local cache
supensour help
```

`platform` is one of `claude`, `copilot`, `antigravity`, `cursor`.
With no platform, the command runs every platform whose CLI is on your PATH
(others are skipped with a notice).

## How each platform is handled

| Platform | Mechanism |
|---|---|
| **Claude Code** | `claude plugin marketplace add <git-url>` + `claude plugin install supensour@supensour` |
| **GitHub Copilot** | `copilot plugin marketplace add supensour/supensour-agent` + `copilot plugin install supensour@supensour` (reads the repo's `.claude-plugin/marketplace.json`) |
| **Antigravity** | `agy plugin install ~/.supensour/supensour-agent` (no github marketplace — installs from the local cache) |
| **Cursor** | No install CLI. The command prints a guide to run `/add-plugin <git-url>` in Cursor chat. |

After an `update`, restart the AI tool's session — plugins and skills load at
session start.

## Requirements

- `bash` (`curl` and `tar` when `git` is not installed — for CLI bootstrap and skill cache)
- The CLI for each platform you target (`claude`, `copilot`, `agy`, `cursor`)
- Windows: use Git Bash or WSL


## License

MIT