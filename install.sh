#!/bin/bash
# install.sh — Adds the clauden notification wrapper to ~/.zshrc

set -euo pipefail

ZSHRC="$HOME/.zshrc"
END_MARKER="# ----- End Mac Setup additions -----"

# 1. Check ~/.zshrc exists
if [ ! -f "$ZSHRC" ]; then
    echo "Error: $ZSHRC not found."
    exit 1
fi

# 2. Check for existing clauden function
if grep -q '^clauden()' "$ZSHRC"; then
    echo "clauden function already exists in $ZSHRC — nothing to do."
    exit 0
fi

# 3. Back up ~/.zshrc
backup="$ZSHRC.backup.$(date +%Y%m%d%H%M%S)"
cp "$ZSHRC" "$backup"
echo "Backed up $ZSHRC to $backup"

# 4. Check for end marker
if ! grep -qF "$END_MARKER" "$ZSHRC"; then
    echo "Error: Could not find '$END_MARKER' in $ZSHRC."
    echo "Please add the clauden function manually."
    exit 1
fi

# 5. Insert clauden function before the end marker
tmpfile=$(mktemp)
while IFS= read -r line; do
    if [ "$line" = "$END_MARKER" ]; then
        cat <<'FUNC'
# Claude Code notification wrapper
clauden() {
    claude "$@"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        osascript -e 'display notification "Claude Code task finished" with title "Task Complete" sound name "Glass"'
    else
        osascript -e 'display notification "Claude Code task failed" with title "Task Failed" sound name "Basso"'
    fi
    return $exit_code
}

FUNC
    fi
    printf '%s\n' "$line"
done < "$ZSHRC" > "$tmpfile"

mv "$tmpfile" "$ZSHRC"

echo "Added clauden function to $ZSHRC"
echo ""
echo "Next steps:"
echo "  Run: source ~/.zshrc"
echo "  Or open a new terminal window."
echo ""
echo "Usage: clauden \"your task here\""
