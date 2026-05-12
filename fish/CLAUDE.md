# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Fish shell configuration for macOS (Apple Silicon). It uses Oh My Fish (OMF) for theme/plugin management and organizes functionality across several files.

## File Structure

- `config.fish` — Main config: PATH setup, aliases, abbreviations, and utility functions. Only loads in interactive mode.
- `fzf.fish` — All fzf-related functions, key bindings, and `$FZF_DEFAULT_OPTS` (Dracula theme). Sourced by `config.fish`.
- `peco.fish` — Parallel set of interactive filter functions using peco instead of fzf. Sourced by `config.fish`.
- `conf.d/omf.fish` — Oh My Fish initialization.
- `conf.d/fish_frozen_theme.fish` — Theme migration artifact from fish 4.3 upgrade.
- `functions/awsume.fish` — awsume alias.
- `completions/` — Tab-completion scripts for asdf, awsume, docker.
- `fish_variables` — Universal variable store (managed by fish, not hand-edited).

## Key Design Patterns

**Conditional loading**: Tools are checked with `command -q` or `type -q` before use. eza overrides ls aliases, fd overrides find-based commands, fzf overrides simpler alternatives. Always follow this pattern when adding new tool integrations.

**Dual fuzzy-finder support**: Every interactive workflow has both an fzf variant (`f*` prefix) and a peco variant (`p*` prefix). When adding new interactive functions, provide both.

**Scope conventions**:
- `-gx` for exported globals set at startup
- `-Ux` for universal vars that persist across sessions (used sparingly: `ASDF_NODEJS_VERIFY_RELEASE_SIGNATURES`, `HOMEBREW_PREFIX`)
- `-l` for locals inside functions

**PATH construction**: Done once in `config.fish` with a loop that checks both directory existence and absence from current PATH before prepending.

## Important Functions

| Function | Purpose |
|----------|---------|
| `upgrade-all` | Upgrades brew, asdf, pnpm, npm globals, OMF in one shot |
| `backup [--sync]` | Runs `make backup` or `make backup-sync` from `$SHELL_BACKUP_DIR` |
| `gcp <commit> <new-branch> <base-branch>` | Cherry-picks a commit onto a new branch with fetch/pull/push |
| `ecs-cluster <profile>` | Selects ECS cluster via fzf |
| `fuji_login / fuji_ssm / fuji_vdi / fuji_postgres` | AWS SSM tunnels for the fuji-mips-devlab profile |
| `pnpm_format` | Runs `pnpm format` then `pnpm lint:fix` |
| `mkcd` | `mkdir -p` + `cd` |
| `extract` | Detects and extracts any archive format |

## Key Bindings (interactive)

Defined in `fzf.fish` and `peco.fish`:
- `Ctrl+T` — fzf file finder
- `Ctrl+R` — fzf history search
- `Alt+C` — fzf directory change
- `Ctrl+G` — fzf git branch switch
- `Ctrl+P` — peco history search
- `Alt+P` — peco file finder
- `Ctrl+Alt+B` — peco git branch switch

## Reload / Apply Changes

Fish reads `config.fish` on every new shell. To apply changes in the current session:

```fish
source ~/.config/fish/config.fish
```

To reload a specific sub-file:

```fish
source ~/.config/fish/fzf.fish
source ~/.config/fish/peco.fish
```

## External Dependencies

Core tools expected to be present: `brew`, `nvim`, `fzf`, `peco`, `fd`, `bat`, `eza`, `rg`, `direnv`, `asdf`, `pnpm`, `kubectl`, `aws`, `docker`.
