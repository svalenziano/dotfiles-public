# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). Ubuntu/WSL, bash, VSCode.

## If you're cloning this

Change `dot_gitconfig` before running `chezmoi apply` — it hardcodes my name and
email, and you don't want to commit as me.

## What's deliberately not here

A few files are gitignored on purpose. The chezmoi source directory *is* this
repo, so those files still exist on my disk and are still deployed by
`chezmoi apply` — they just never get published:

| Not published | What it holds |
|---|---|
| `private_dot_config/espanso/match/identity.yml` | espanso snippets for my name, email, phone, address, links |
| `private_dot_config/espanso/match/job_search.yml` | job-search form letters |
| `~/.bashrc.local` | machine-local aliases and paths; not managed by chezmoi at all |

Consequence for me, noted here so I remember: on a **new machine**,
`chezmoi init` clones from GitHub and these files won't exist. Recreate them by
hand.

## License

[MIT](LICENSE).

## Want to run any scripts a-la-carte?
Don't use `source`
```bash
bash script_name.sh
```

## New Machine Setup

### Setup syncthing 
To make transfering ssh keys and other stuff easier
https://apt.syncthing.net/

### Prerequisites

1. Copy SSH keys to `~/.ssh` and set permissions (`chmod 600 ~/.ssh/id_*`, `chmod 644 ~/.ssh/*.pub`)
2. Ensure `git` and `curl` are available (pre-installed on most Ubuntu systems)
3. Install chezmoi: `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:$GITHUB_USERNAME/dotfiles.git`  This method worked for SV. (https://www.chezmoi.io/install/#one-line-package-install)

### Initialize

```bash
chezmoi init --apply git@github.com:svalenziano/dotfiles.git
```

### What Happens on `chezmoi apply`

Chezmoi copies dotfiles to their target locations and runs install scripts. Scripts execute in the following order:

#### Phase 1: `run_once` scripts (run once per machine, in order)

| Order | Script | What it installs |
|-------|--------|------------------|
| 1 | `run_once_01-install-apt.sh` | Core apt packages: build-essential, python3, pipx, git, curl, ffmpeg, imagemagick, PostgreSQL, and more |
| 2 | `run_once_02-install-docker.sh.tmpl` | Docker Engine (skipped on WSL) |
| 3 | `run_once_03-install-gh.sh` | GitHub CLI |
| 4 | `run_once_04-install-nvm.sh` | nvm + latest LTS Node.js |
| 5 | `run_once_05-install-pipx.sh` | pipx packages: poetry, httpie, ruff |

#### Phase 2: `run_onchange` scripts (run when script content changes)

These install CLI tools from GitHub releases. They re-run whenever you bump the version in the script.

| Script | Tool |
|--------|------|
| `run_onchange_install-fd.sh` | [fd](https://github.com/sharkdp/fd) (find alternative) |
| `run_onchange_install-micro.sh` | [micro](https://github.com/zyedidia/micro) (terminal editor) |
| `run_onchange_install-rg.sh` | [ripgrep](https://github.com/BurntSushi/ripgrep) |
| `run_onchange_install_jq.sh` | [jq](https://github.com/jqlang/jq) (JSON processor) |
| `run_onchange_install_pandoc.sh` | [pandoc](https://github.com/jgm/pandoc) (document converter) |

#### Phase 3: Dotfiles

Key config files applied to `~`:

- `.bashrc` — shell config with custom prompt, aliases, ssh-agent, WSL detection
- `.bashrc.d/` — modular shell extensions (pdf utilities, sync, youtube)
- `.gitconfig` — git user, VSCode as diff/merge tool, credential helper via `gh`
- `.npmrc`, `.pylintrc`, `.profile`, `.bash_profile`

### Post-Apply Manual Steps

1. **GitHub CLI auth** — run `gh auth login` to enable the credential helper in `.gitconfig`
2. **Docker group** — log out and back in for the `docker` group to take effect
3. **VSCode** — install separately (used as default editor and diff tool)
4. **chezmoi binary** — the `.bashrc` aliases `chezmoi` to `~/bin/chezmoi`; ensure the binary is at that path

### Updating

To bump a tool version, edit the `VERSION=` line in the corresponding `run_onchange` script and run `chezmoi apply`.

For `run_once` scripts, chezmoi tracks that they've already run. To force a re-run, use `chezmoi state delete-bucket --bucket=scriptState`.
