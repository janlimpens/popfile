#!/usr/bin/env bash
# Set up agent worktrees and generate AGENT.md files from AGENT.template.md.
# Worktrees are created at ../Claude/popfile/agent{N} relative to the repo root.
#
# Usage: ./agents/make-agents.sh [numbers...]
#   ./agents/make-agents.sh        # sets up agent2 and agent3
#   ./agents/make-agents.sh 2 3 4  # sets up specified agents

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/AGENT.template.md"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKTREE_BASE="$(cd "$REPO/.." && pwd)/Claude/popfile"
AGENTS=("${@:-2 3}")

for N in "${AGENTS[@]}"; do
    DIR="$WORKTREE_BASE/agent${N}"
    BRANCH="agent${N}"

    # Create worktree + branch if it doesn't exist yet
    if ! git -C "$REPO" worktree list | grep -q "$DIR"; then
        if git -C "$REPO" show-ref --verify --quiet "refs/heads/$BRANCH"; then
            git -C "$REPO" worktree add "$DIR" "$BRANCH"
        else
            git -C "$REPO" worktree add -b "$BRANCH" "$DIR" main
        fi
        echo "created worktree agent${N} ($DIR)"
    else
        echo "worktree agent${N} already exists, skipping"
    fi

    # Generate AGENT.md from template
    sed "s/{{N}}/${N}/g" "$TEMPLATE" > "$DIR/AGENT.md"
    echo "wrote agent${N}/AGENT.md"

    # Create inbox/outbox if missing
    touch "$DIR/inbox.md" "$DIR/outbox.md"
done
