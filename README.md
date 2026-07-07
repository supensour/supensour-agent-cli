# supensour-agent-cli

Install [supensour-agent](https://github.com/supensour/supensour-agent) skills as a
**plugin** into your AI coding tools — at global (user) scope, from one command.

Supported platforms: **Claude Code**, **GitHub Copilot CLI**, **Antigravity CLI**, **Cursor**.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/supensour/supensour-agent-cli/master/install-remote.sh | bash
```

Restart your shell afterward.

## Usage

```bash
supensour init                          # clone/refresh the local skill cache
supensour plugins install [platform]    # install the plugin
supensour plugins update  [platform]    # update the plugin
supensour update                        # update the supensour CLI itself
supensour help
```

**Commands**

- `init` — clone or refresh the local skill cache (`git` or `curl` + `tar` fallback)
- `plugins install [platform]` — install the plugin for one platform, or all detected platforms if omitted
- `plugins update [platform]` — update the plugin for one platform, or all detected platforms if omitted
- `update` — update the **CLI itself** to the latest release (same mechanism as the install command below)
- `help` — print usage (`-h` and `--help` are equivalent)

**`platform`** — `claude` | `copilot` | `antigravity` | `cursor`

Omit `platform` to run every platform whose CLI is on your PATH (others are skipped). Pass a
platform to target one tool only — that fails if its CLI is missing.

Restart your shell after installing the CLI. Restart the AI tool session after a plugin update —
plugins and skills load at session start.

```bash
supensour plugins install              # all detected tools
supensour plugins install claude       # one platform
supensour plugins update antigravity   # update one plugin
supensour update                       # update the CLI itself
```

> Older `supensour install` / `supensour update <platform>` still work but print a
> deprecation notice — use the `plugins` forms.

## Requirements

- `bash` (`curl` and `tar` when `git` is not installed — for CLI bootstrap and skill cache)
- The CLI for each platform you target (`claude`, `copilot`, `agy`, `cursor`)
- Windows: use Git Bash or WSL



## License

MIT