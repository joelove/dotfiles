#!/bin/bash
# Public pi-box parity: everything the box can configure without secrets.
#
# The candela-infra first-boot payload clones this public repo and runs this
# script, and pi-config-sync.sh runs it again, so a replaced box comes up
# styled, named, and mosh-attachable without the operator. Idempotent. Secret
# or account-scoped steps stay in candela-infra's pi-config-sync.sh:
# agent-skills, the Candela repos, gh auth, aws login, the app .env files, the
# WireGuard peer, and the Linear MCP sign-in.
#
#   pi-box-parity.sh [--terminfo FILE] [--pubkey FILE]
#
# --terminfo is an `infocmp -x xterm-ghostty` dump and --pubkey an SSH public
# key for the mosh bootstrap. Both default to the copies committed beside this
# script under pi-box/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="${SCRIPT_DIR}/../pi-box"

DOTFILES_REPO="${PI_BOX_DOTFILES_REPO:-https://github.com/joelove/dotfiles.git}"
PI_PLAN_REPO="${PI_BOX_PI_PLAN_REPO:-https://github.com/joelove/pi-plan-build.git}"
PI_PLAN_BRANCH="${PI_BOX_PI_PLAN_BRANCH:-personal}"

TERMINFO_FILE="${ASSETS_DIR}/xterm-ghostty.terminfo"
PUBKEY_FILE="${ASSETS_DIR}/pi-box-mac.pub"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --terminfo) TERMINFO_FILE="$2"; shift 2 ;;
    --pubkey)   PUBKEY_FILE="$2"; shift 2 ;;
    *) echo "pi-box-parity: unknown argument: $1" >&2; exit 2 ;;
  esac
done

PROJECTS="${HOME}/Projects"
mkdir -p "${PROJECTS}"

clone_or_pull() {
  local url="$1" dir="$2"
  if [[ -d "${dir}/.git" ]]; then
    git -C "${dir}" checkout main
    git -C "${dir}" pull --ff-only
  else
    git clone "${url}" "${dir}"
  fi
}

# dotfiles: the shared pi, tmux, and git-hook config.
clone_or_pull "${DOTFILES_REPO}" "${PROJECTS}/dotfiles"

# pi-plan-build is a pi package loaded from a local path in settings.json. The
# path resolves relative to the linked settings file, so it must live at
# ~/Projects/pi-plan-build.
if [[ -d "${PROJECTS}/pi-plan-build/.git" ]]; then
  git -C "${PROJECTS}/pi-plan-build" fetch origin --quiet || true
  git -C "${PROJECTS}/pi-plan-build" checkout -q "${PI_PLAN_BRANCH}"
  git -C "${PROJECTS}/pi-plan-build" pull --ff-only
else
  git clone --branch "${PI_PLAN_BRANCH}" "${PI_PLAN_REPO}" "${PROJECTS}/pi-plan-build"
fi

# pi agent config, git hooks, and the box tmux config.
if [[ -x "${PROJECTS}/dotfiles/scripts/setup-linux.sh" ]]; then
  "${PROJECTS}/dotfiles/scripts/setup-linux.sh"
fi

# Public skills only; the private tree is added by pi-config-sync.sh.
mkdir -p "${HOME}/.agents/skills"
for skill in "${PROJECTS}/dotfiles/.agents/skills"/*/; do
  [[ -d "${skill}" ]] || continue
  ln -sfn "${skill%/}" "${HOME}/.agents/skills/$(basename "${skill}")"
done

git config --global core.hooksPath "${HOME}/.config/git/hooks"
chmod +x "${HOME}/.config/git/hooks/"* 2>/dev/null || true

# tmux plugin manager and tmux-nova. Cloning is enough: the `run tpm` line in
# ~/.tmux.conf sources each plugin's .tmux file.
TPM="${HOME}/.tmux/plugins/tpm"
NOVA="${HOME}/.tmux/plugins/tmux-nova"
mkdir -p "${HOME}/.tmux/plugins"
[[ -d "${TPM}/.git" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "${TPM}"
[[ -d "${NOVA}/.git" ]] || git clone --depth 1 https://github.com/o0th/tmux-nova "${NOVA}"
chmod +x "${TPM}"/*.sh "${TPM}"/bin/* "${NOVA}"/scripts/*.sh 2>/dev/null || true

# mosh is not in the AL2023 repos and there is no EPEL, so build 1.4.0 from
# source. All build dependencies are in amazonlinux.
if ! command -v mosh-server >/dev/null 2>&1; then
  sudo dnf install -y protobuf-compiler protobuf-devel ncurses-devel zlib-devel \
    openssl-devel gcc-c++ make autoconf automake pkgconf-pkg-config perl-diagnostics
  mosh_tmp="$(mktemp -d)"
  curl -fsSL --retry 3 \
    https://github.com/mobile-shell/mosh/releases/download/mosh-1.4.0/mosh-1.4.0.tar.gz \
    -o "${mosh_tmp}/mosh.tar.gz"
  tar -xzf "${mosh_tmp}/mosh.tar.gz" -C "${mosh_tmp}"
  ( cd "${mosh_tmp}/mosh-1.4.0" && ./configure --prefix=/usr/local && make -j"$(nproc)" && sudo make install )
  rm -rf "${mosh_tmp}"
fi

# xterm-ghostty terminfo. The SSM path sets its own TERM, but mosh and SSH from
# Ghostty send xterm-ghostty and the box has no entry for it.
if [[ -f "${TERMINFO_FILE}" ]] && command -v tic >/dev/null 2>&1; then
  mkdir -p "${HOME}/.terminfo"
  tic -x -o "${HOME}/.terminfo" "${TERMINFO_FILE}" >/dev/null 2>&1 || true
fi

# SSH public key for the mosh bootstrap.
if [[ -f "${PUBKEY_FILE}" ]]; then
  pubkey="$(cat "${PUBKEY_FILE}")"
  if [[ -n "${pubkey}" ]]; then
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    touch "${HOME}/.ssh/authorized_keys"
    chmod 600 "${HOME}/.ssh/authorized_keys"
    grep -qF "${pubkey}" "${HOME}/.ssh/authorized_keys" ||
      printf '%s\n' "${pubkey}" >> "${HOME}/.ssh/authorized_keys"
  fi
fi

# EC2 derives a long ip-... name from cloud-init; set the short static name and
# stop cloud-init from overwriting it on reboot.
sudo hostnamectl set-hostname pi-box
printf 'pi-box\n' | sudo tee /etc/hostname >/dev/null
printf 'preserve_hostname: true\n' | sudo tee /etc/cloud/cloud.cfg.d/99-preserve-hostname.cfg >/dev/null
grep -qE '(^|[[:space:]])pi-box([[:space:]]|$)' /etc/hosts ||
  printf '127.0.0.1 pi-box\n' | sudo tee -a /etc/hosts >/dev/null

echo "pi parity complete"
