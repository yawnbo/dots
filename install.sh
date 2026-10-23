#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./install.sh [build|switch] [profile]

build   Build the Home Manager configuration without activating it.
switch  Build and activate after confirmation (default). Back up conflicts.
        Register Nix's Zsh in /etc/shells and set it as your login shell.

The default profile is <architecture>-<darwin|linux>.
The current username, HOME, and checkout path are passed with --impure.
Run as your own account, not root. If Nix is missing, this script runs the
official multi-user Nix installer, which can request sudo access. It then
continues with Home Manager without requiring a new shell. A successful switch
also uses sudo if needed to register and select Zsh. Build leaves the login
shell unchanged. This script does not remove packages or install Pi or VTR.
EOF
}

case "${1:-switch}" in
    -h|--help) usage; exit 0 ;;
    build|switch) action="${1:-switch}" ;;
    *) usage >&2; exit 2 ;;
esac
if (( $# > 2 )); then
    usage >&2
    exit 2
fi

if [[ "$(id -u)" == 0 ]]; then
    echo 'Run this installer as your own account, not root or sudo.' >&2
    exit 1
fi
if [[ "${HOME:-}" != /* || "$HOME" == / || ! -d "$HOME" ]]; then
    echo 'HOME must be an existing absolute directory other than /.' >&2
    exit 1
fi

case "$(uname -s)" in
    Darwin) platform=darwin ;;
    Linux) platform=linux ;;
    *) echo 'Only macOS and Linux are supported.' >&2; exit 1 ;;
esac
case "$(uname -m)" in
    arm64|aarch64) architecture=aarch64 ;;
    x86_64|amd64) architecture=x86_64 ;;
    *) echo 'Only 64-bit ARM and x86 are supported.' >&2; exit 1 ;;
esac

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
profile="${2:-${architecture}-${platform}}"
DOTS_USERNAME="$(id -un)"
export DOTS_USERNAME
export DOTS_HOME="$HOME"
export DOTS_CHECKOUT="$script_dir"

# Git-backed flakes include tracked files only. Do not use path: here: it can
# copy ignored files (including local secrets) into the world-readable store.
if ! git -C "$script_dir" ls-files --error-unmatch -- \
    flake.nix flake.lock home/default.nix home/lorri.nix >/dev/null 2>&1; then
    echo 'Track the new Nix files before running the Git-backed flake:' >&2
    echo '  git add flake.nix flake.lock home/default.nix home/lorri.nix' >&2
    exit 1
fi

# Also enable these features for the Home Manager subprocess on first setup.
export NIX_CONFIG="${NIX_CONFIG:-}
extra-experimental-features = nix-command flakes"

printf 'Profile: %s\nAccount: %s\nHome: %s\nCheckout: %s\n' \
    "$profile" "$DOTS_USERNAME" "$DOTS_HOME" "$DOTS_CHECKOUT"
args=("$action" --impure --flake "$script_dir#$profile")
if [[ "$action" == switch ]]; then
    backup="hm-backup-$(date -u +%Y%m%dT%H%M%SZ)-$$"
    printf 'Apply %s and set Nix Zsh as your login shell? Conflicting files will be backed up with suffix .%s. [y/N] ' \
        "$profile" "$backup"
    read -r answer || exit 1
    case "$answer" in
        y|Y|yes|YES) ;;
        *) echo 'Cancelled.'; exit 0 ;;
    esac
    args+=(-b "$backup")
fi

load_nix() {
    local profile_script
    for profile_script in \
        /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
        "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
        if [[ -r "$profile_script" ]]; then
            source "$profile_script"
            if command -v nix >/dev/null 2>&1; then
                return 0
            fi
        fi
    done
}

if ! command -v nix >/dev/null 2>&1; then
    # Reuse an installation whose shell environment has not been loaded yet.
    load_nix
fi
if ! command -v nix >/dev/null 2>&1; then
    if ! command -v curl >/dev/null 2>&1; then
        echo 'Install curl first; it is required to download the Nix installer.' >&2
        exit 1
    fi
    echo 'Installing Nix with the official multi-user installer (sudo may be required).'
    nix_installer="$(mktemp "${TMPDIR:-/tmp}/dots-nix-install.XXXXXX")"
    trap 'rm -f -- "$nix_installer"' EXIT
    # Download completely before executing; do not execute a partial response.
    curl --fail --show-error --location --proto '=https' --proto-redir '=https' \
        --output "$nix_installer" https://nixos.org/nix/install
    sh "$nix_installer" --daemon
    rm -f -- "$nix_installer"
    trap - EXIT
    load_nix
    if ! command -v nix >/dev/null 2>&1; then
        echo 'The Nix installer finished, but nix is still unavailable. Check its installation output.' >&2
        exit 1
    fi
fi

nix run "$script_dir#home-manager" -- "${args[@]}"

if [[ "$action" == switch ]]; then
    # Use the stable profile link, not a store path that can be garbage-collected.
    login_shell="$HOME/.nix-profile/bin/zsh"
    if [[ ! -x "$login_shell" ]] || ! "$login_shell" -f -c 'exit 0'; then
        echo 'Home Manager was activated, but its Zsh cannot start. Login shell unchanged.' >&2
        exit 1
    fi
    case "$platform" in
        linux)
            account_record="$(getent passwd "$DOTS_USERNAME")"
            current_shell="${account_record##*:}"
            ;;
        darwin)
            account_record="$(dscl . -read "/Users/$DOTS_USERNAME" UserShell)"
            current_shell="${account_record#UserShell: }"
            ;;
    esac
    if ! grep -Fxq -- "$login_shell" /etc/shells; then
        echo "Registering $login_shell in /etc/shells (sudo may be required)."
        printf '%s\n' "$login_shell" | sudo tee -a /etc/shells >/dev/null
    fi
    if [[ "$current_shell" != "$login_shell" ]]; then
        echo "Setting the login shell for $DOTS_USERNAME to $login_shell."
        sudo chsh -s "$login_shell" "$DOTS_USERNAME"
    fi
    echo 'Zsh is registered as your login shell. Reconnect or open a new login session.'
fi
