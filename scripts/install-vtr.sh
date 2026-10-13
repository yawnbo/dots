#!/usr/bin/env bash
# Keep private release access outside Nix evaluation and the public flake lock.
set -euo pipefail

case "$(uname -s)" in
    Darwin)
        echo 'VTR Linux binary install skipped on macOS.'
        exit 0
        ;;
    Linux) ;;
    *) echo 'The VTR release installer supports Linux only.' >&2; exit 1 ;;
esac

if command -v vtr >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/vtr" ]]; then
    echo 'VTR already installed.'
    exit 0
fi

# Same private release endpoint used by the previous install.sh.
release_host="${VITREA_RELEASE_SSH_HOST:-yawnbonetcup@server.yawnbo.com}"
echo "Installing VTR from $release_host..."
ssh -o BatchMode=yes "$release_host" \
    'cat /home/yawnbonetcup/releases/vtr/install.sh' | \
    VITREA_RELEASE_SSH_HOST="$release_host" bash
echo 'VTR installed successfully.'
