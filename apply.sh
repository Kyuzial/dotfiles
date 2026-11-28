#!/usr/bin/env bash
# apply.sh — install config symlinks, then commit & push the repo.
#
# Usage:
#   ./apply.sh                  # apply symlinks, commit & push (auto message)
#   ./apply.sh "my message"     # same, with a custom commit message
#   ./apply.sh --no-push        # apply + commit only, skip the push
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# ---------------------------------------------------------------------------
# Config symlinks. Format: "repo path:absolute link path"
# Add a line here to manage another config the same way.
# ---------------------------------------------------------------------------
LINKS=(
    "${REPO}/config/hyprland:${HOME}/.config/hypr"
    "${REPO}/config/waybar:${HOME}/.config/waybar"
)

apply_links() {
    for pair in "${LINKS[@]}"; do
        target="${pair%%:*}"
        link="${pair##*:}"

        if [[ ! -e "$target" ]]; then
            echo "✗ target $target does not exist, skipping" >&2
            continue
        fi

        if [[ -L "$link" ]]; then
            if [[ "$(readlink "$link")" == "$target" ]]; then
                echo "✓ $link (already linked)"
            else
                ln -sfn "$target" "$link"
                echo "↻ $link repointed → $target"
            fi
        elif [[ -e "$link" ]]; then
            echo "✗ $link exists and is not a symlink — move it aside first:" >&2
            echo "    mv $link $link.bak" >&2
            exit 1
        else
            ln -s "$target" "$link"
            echo "+ $link → $target"
        fi
    done
}

# ---------------------------------------------------------------------------
# Git: commit & push
# ---------------------------------------------------------------------------
sync_git() {
    local push=1 msg
    if [[ "${1:-}" == "--no-push" ]]; then
        push=0
        shift
    fi
    msg="${1:-Dotfiles update $(date '+%Y-%m-%d %H:%M')}"

    cd "$REPO"
    git add -A

    if git diff --cached --quiet; then
        echo "✓ nothing to commit"
        return
    fi

    git commit -m "$msg"

    if (( push )); then
        git pull --rebase --autostash
        git push
        echo "✓ committed & pushed: $msg"
    else
        echo "✓ committed: $msg"
    fi
}

apply_links

if [[ "${1:-}" == "--no-push" || -n "${1:-}" ]]; then
    sync_git "$@"
else
    sync_git
fi
