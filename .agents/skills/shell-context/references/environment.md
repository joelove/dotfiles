# Shell environment inventory

## What shell runs

- The user's interactive/login shell is zsh 5.9 at `/bin/zsh` (`$SHELL` is
  `/bin/zsh`). The config is written for zsh, not bash.
- Pi's `bash` tool is configured with `shellPath: "/bin/zsh"`, so it launches
  `/bin/zsh -c "<command>"`.
- It runs non-interactively. `~/.zshrc`, `~/.zprofile`, and `~/.zlogin` are
  skipped. `~/.zshenv` is read for non-interactive shells, so anything exported
  there (for example `~/.secrets`) is available.

## Shell config

- `~/.zshrc` sets `ZSH="$HOME/.oh-my-zsh"` and sources oh-my-zsh with the
  plugins `git npm macos yarn node aws history direnv`.
- Theme is `powerlevel10k` (interactive only).
- `~/.zshrc` mutates `PATH` with `~/.yarn/bin`, `~/.config/yarn/global/node_modules/.bin`,
  `/usr/local/bin`, `~/.local/bin`, `~/node_modules/.bin`,
  `/opt/homebrew/opt/make/libexec/gnubin`,
  `/opt/homebrew/opt/postgresql@17/bin`, `~/.cargo/bin`, `~/.bun/bin`,
  `~/Library/pnpm`, plus nvm (node v24.12.0), pyenv, zoxide, fzf, poetry, bun.
- `~/.zshrc` sets `EDITOR="cursor"` and `GIT_EDITOR="vim"`.
- `~/.zshenv` sources `~/.automations.sh` and `~/.secrets`.

The environment pi inherits is already the environment of the zsh session that
launched pi, so `PATH` and exported variables are generally correct.

## Aliases and functions

Because the tool runs non-interactively, aliases and functions are not
available by default. Two different rules apply:

- **Functions** work as soon as they are defined in the current process.
  ```bash
  source ~/.zshrc >/dev/null 2>&1
  get_current_branch
  ```
- **Aliases are expanded at parse time**, before execution. Sourcing an alias in
  the same `zsh -c` string does not make it available to later lines. Force a
  runtime parse with `eval`:
  ```bash
  source ~/.zshrc >/dev/null 2>&1
  eval "l"        # alias l='ls -lah'
  ```

Common user commands: `recent`, `deploy <service> [env] [branch]`,
`deploy_status`, `pr [base] [branch]`, `assume_profile <name>`,
`list_profiles`, `die <port>`, `del <filename>`, `gpshr [remote]`, `ty <pkg>`,
`proxy`, `colors`.

## Verify the shell

```bash
printf 'shell=%s zsh=%s\n' "$SHELL" "$ZSH_VERSION"
# Running inside pi's bash tool this prints zsh, for example shell=/bin/zsh zsh=5.9
```
