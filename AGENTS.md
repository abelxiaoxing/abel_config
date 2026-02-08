# Repository Guidelines

## Project Structure

- `autoinstall.sh`: interactive entrypoint (sync configs, install packages, update mirrors).
- `config.sh`: module lists and sync targets (`CONFIG_DIRS`, `SYSTEM_CONFIG_FILES`, `PACKAGE_LIST`).
- `functions.sh`: shared Bash functions used by the menu actions.
- `chezmoi/`: user dotfiles managed by chezmoi (source of truth for `~/.config/**` and `~/.zshrc`).
- `backgrounds/`: wallpapers synced to `/usr/share/backgrounds` (requires `sudo`).
- `pacman.conf`, `paru.conf`: system-level config templates (written to `/etc`, requires `sudo`).

## Build, Test, and Development Commands

This repo is mostly shell scripts + dotfiles (no “build” step).

- Run the tool: `./autoinstall.sh`
- Preview user config changes: `chezmoi --source ./chezmoi diff`
- Apply user configs only: `chezmoi --source ./chezmoi apply`
- Import a new config into the repo: `chezmoi --source ./chezmoi add ~/.config/<module>`
- Quick script sanity checks:
  - `bash -n autoinstall.sh config.sh functions.sh`
  - `shellcheck autoinstall.sh config.sh functions.sh` (if installed)

## Coding Style & Naming Conventions

- Bash: 2-space indentation; `snake_case` function names; uppercase for “constants”/arrays.
- Keep “data” in `config.sh` and “logic” in `functions.sh`.
- Chezmoi naming:
  - `chezmoi/dot_zshrc` → `~/.zshrc`
  - `chezmoi/dot_config/<app>/...` → `~/.config/<app>/...`
- When adding a new config module, add it to `CONFIG_DIRS` in `config.sh` and update `README.md`.

## Testing Guidelines

There is no automated test suite. Validate changes by:

- Using `chezmoi --source ./chezmoi status` / `diff` before `apply`.
- Running `./autoinstall.sh` in a VM or disposable user environment (it may install packages and modify `/etc`).

## Commit & Pull Request Guidelines

- Commit subjects are short and component-focused; existing history commonly uses Chinese verbs like `添加/修复/更新/调整` (example: `修复 蓝牙缺失问题`).
- PRs should include: summary, verification steps, and screenshots for UI changes (Hyprland/Waybar/Rofi). Call out any `sudo`-required impacts.

## Security & Configuration Tips

- Do not commit secrets (tokens, API keys, private keys).
- Keep machine-specific values out of tracked files; prefer local overrides or chezmoi-managed templates where appropriate.
