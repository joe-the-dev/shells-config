# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Make-based dotfiles/config-management system for macOS: it backs up and restores settings for shells (fish/bash/zsh), dev tools (asdf, git, Homebrew), Neovim, and app preferences (Karabiner, Hammerspoon, iTerm2). There is no application code, build step, or test suite — the repo *is* the config, and the Makefile is the tool that moves it between this repo and `$HOME`. (Two features were removed as broken: macOS *system* settings backup/restore — Dock, Finder, display, etc. via `defaults export`/`import` — had gone stale/empty on modern macOS; JetBrains IDE config backup/restore was removed for the same reason — silently backing up/restoring nothing useful.)

`AGENTS.md` at the repo root already contains a detailed agent maintenance guide (architecture, per-tool source→target table, troubleshooting, code patterns for adding new tools). Read it — this file only adds pointers and gotchas, it does not duplicate that content.

## Commands

```bash
make help             # list all targets
make install           # full install (default target)
make install-minimal   # git, fish, nvim only
make install-dev       # brew, asdf
make install-tools     # karabiner, hammerspoon, iterm2
make backup             # full backup into this repo
make backup-sync        # backup + git commit + push
make backup-apps        # app configs only
make restore             # restore everything from this repo to $HOME
make status              # show current config status
make dry-run              # preview an install/backup without executing
make validate-config       # check config file syntax
make check-deps             # verify required deps are installed
make -n <target>              # dry-run any single target (make's own -n flag)
make <underscored-target>      # run one internal step directly, e.g. make _backup-fish, make _copy-nvim
```

No test framework exists. CI (`.github/workflows/ci.yml`) validates `Makefile` syntax and Fish config syntax on push/PR to `main`/`master`/`develop` — that's the closest thing to "tests" here; run the same checks locally with `make --dry-run --just-print help` and `fish -n <file>` before pushing Makefile or fish changes.

## Architecture

- `Makefile` — entry point: defines shared vars (`HOME_DIR`, `CONFIG_DIR`, `ITERM2_APP_SUPPORT`, etc., exported to sub-makefiles) and `include`s the modules below.
- `makefiles/install.mk` — installation/restore targets.
- `makefiles/backup.mk` — all backup targets.
- `makefiles/utils.mk` — status/validate/check-deps/clean/dry-run.
- `makefiles/dependencies.mk` — dependency graph / `install-smart`.

Every tool follows the same symmetric pattern: a `<toolname>/` directory in the repo root mirrors a real config location under `$HOME` (or `~/Library/Application Support/...` for iTerm2). Backup targets are named `_backup-<tool>` (rsync from `$HOME` into the repo), install/copy targets are `_copy-<tool>` (copy from the repo into `$HOME`); public targets (`backup`, `restore`, `install`, etc.) orchestrate the underscore-prefixed private ones. When adding a new tool, follow this exact pattern — see the "Adding a New Application" example in `AGENTS.md`.

Backup/install operations run in parallel batches for speed (see `.parallel_log.tmp` / batch logic in `backup.mk`/`install.mk`).

## Gotchas

- This repo commits real personal config data (git identity, etc.). Before adding backup logic for a new domain, check `.gitignore` and extend it rather than committing secrets or machine-churny files by accident.
- `env/home.env` and any `.env*` are gitignored; only `env/template.env` should ever hold real content in git.
- `make restore` overwrites live machine state — treat it as destructive; prefer `make dry-run` first when unsure.
- `git branch` for backups is enforced as `main` by `backup-sync`; auto-commits use the message format `"Backup configs - YYYY-MM-DD HH:MM:SS"`.
- Before adding any new `defaults export`/`import`-based backup (macOS system prefs, another app's plist), verify the domain actually round-trips on the current macOS version first (`defaults export <domain> - | wc -c` — an ~42-byte result is an empty dict). Apple regularly moves preference storage (ByHost files, sandboxed containers, merged domains); a domain that worked in an old macOS version can silently export nothing today, which is exactly why the macOS-settings feature was removed.
