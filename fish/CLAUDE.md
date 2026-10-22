# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal fish shell configuration (`~/.config/fish`), managed via Oh My Fish (OMF). There is no
build, lint, or test tooling — changes are validated by opening a new interactive fish shell (or
running `source ~/.config/fish/config.fish`) and exercising the affected function/keybinding.

## Sourcing order (matters for debugging)

1. `config.fish` runs first for every shell (login/non-interactive too, until the early `exit` on
   the `status is-interactive` check near the top).
2. Homebrew, asdf, direnv are conditionally hooked in based on what's installed.
3. `conf.d/*.fish` is autoloaded by fish itself (not sourced explicitly) — `omf.fish` boots Oh My
   Fish (`$OMF_PATH/init.fish`), and the two `fish_frozen_*.fish` files are fish-4.3 migration
   artifacts (universal → global scope for key bindings/theme). Don't edit the frozen files;
   change key bindings/theme in `config.fish` instead per the comments in those files.
4. At the bottom of `config.fish`, `fzf.fish` and `peco.fish` are sourced explicitly (in that
   order). Both configure the *same categories* of interactive tools (fuzzy history search, file
   find, cd, git branch/status browsers, docker/kubectl/aws pickers) — fzf's are the primary,
   feature-rich versions; peco's are lighter alternatives. **Their key bindings overlap and the
   later one wins**: e.g. `\cg` is bound by fzf (git branch switcher) but not overridden by peco;
   `\cp` is bound by fzf's default-opts setup implicitly unused but then explicitly rebound by
   peco.fish to `ph` (peco history) — check both files when a binding doesn't do what you expect.
5. `functions/*.fish` (e.g. `awsume.fish`, `fuji.fish`) are autoloaded lazily by fish on first
   call, standard fish convention — one function (or a couple of tightly related ones) per file,
   filename matching the function name.
6. `completions/*.fish` are autoloaded completions for `asdf`, `awsume`, `docker`.

## Key bindings map (interactive only)

Both `fzf.fish` and `peco.fish` guard their `bind` calls with `if status is-interactive`. Current
bindings, in load order:

- `\ct` → `ff` (fzf file finder)
- `\cr` → `fh` (fzf history search)
- `\ec` → `fcd` (fzf cd)
- `\cg` → `fgb` (fzf git branch switcher)
- `\e\cg` → `fgs` (fzf git status files)
- `\e\cp` → `fproject` (fzf project switcher)
- `\cp` → `ph` (peco history search — overrides fzf defaults for Ctrl+P)
- `\ep` → `pf` (peco file finder)
- `\eP` → `pcd` (peco cd)
- `\e\cb` → `pgb` (peco git branch switcher)

When adding a new binding, grep both `fzf.fish` and `peco.fish` first to avoid clashing with an
existing one.

## Function naming convention

- `f<x>` = fzf-backed picker (e.g. `ff`, `fcd`, `fgb`, `fgs`, `fkill`, `fssh`, `fdocker`,
  `fproject`, `fnpm`, `fkube`, `faws`, `fecs`, `frg`).
- `p<x>` = peco-backed equivalent of the same picker (e.g. `pf`, `pcd`, `pgb`, `pgs`, `pdocker`,
  `pproject`, `pkube`, `paws`, `pecs`, `prg`). Peco versions are intentionally simpler (no
  preview windows) — don't add preview logic to them; that's what the fzf versions are for.
- Short aliases exist for a handful of these (`fif`→`ff`, `fgit`→`fgl`, `pk`→`fkill`,
  `hist`→`fh`, `pecoh`/`pecof`/`pecocd`/`pecogit`/`pecopk`→ their peco counterparts). Check the
  alias blocks at the bottom of each file before introducing a new alias that might collide.

## AWS/SSO functions (`functions/fuji.fish`)

Client-specific (Fuji/MIPS) SSO login and SSM port-forwarding helpers hardcoded to a specific
instance ID, region (`ap-southeast-2`), and profile (`fuji-mips-devlab`). Treat these as
credentials-adjacent — do not generalize or copy the hardcoded instance ID/host values into
examples for other contexts.

## Environment specifics

- `SSH_AUTH_SOCK` is pointed at Secretive's agent socket (`~/Library/Containers/com.maxgoedjen...`)
  — this is macOS-specific and required for SSH key signing via the Secure Enclave.
- `$HOME/.env` is sourced via `bass` (bash-syntax env loader) if present — actual secrets live
  outside this repo.
- The `backup` function shells out to `make backup` / `make backup-sync` in `$SHELL_BACKUP_DIR`,
  a separate directory (not this repo) that presumably contains the Makefile-based backup system.
