#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./install.sh [build|switch] [profile]

build   Build the Home Manager configuration without activating it.
switch  Build and activate after confirmation (default). Back up conflicts.

The default profile is <architecture>-<darwin|linux>.
The current username, HOME, and checkout path are passed with --impure.
Run as your own account, not root. Install Nix first. This script does not
install Nix, change your login shell, remove packages, or install Pi or VTR.
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

if ! command -v nix >/dev/null 2>&1; then
    echo 'Nix is not installed or is not on PATH.' >&2
    echo 'Install Nix, open a new shell, then run this script again. See README.md.' >&2
    exit 1
fi

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
    printf 'Apply %s? Conflicting files will be backed up with suffix .%s. [y/N] ' \
        "$profile" "$backup"
    read -r answer || exit 1
    case "$answer" in
        y|Y|yes|YES) ;;
        *) echo 'Cancelled.'; exit 0 ;;
    esac
    args+=(-b "$backup")
fi

exec nix run "$script_dir#home-manager" -- "${args[@]}"
