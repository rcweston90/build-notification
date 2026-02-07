#!/bin/bash
# install.sh — Sets up macOS notifications for Claude Code
#   1. Adds clauden wrapper to ~/.zshrc (notifies on task complete/fail)
#   2. Adds Notification hook to ~/.claude/settings.json (notifies when Claude needs input)

set -euo pipefail

ZSHRC="$HOME/.zshrc"
SETTINGS="$HOME/.claude/settings.json"
END_MARKER="# ----- End Mac Setup additions -----"

# ── Part 1: clauden wrapper in ~/.zshrc ──────────────────────────────

install_clauden() {
    if [ ! -f "$ZSHRC" ]; then
        echo "Error: $ZSHRC not found."
        return 1
    fi

    if grep -q '^clauden()' "$ZSHRC"; then
        echo "clauden function already exists in $ZSHRC — skipping."
        return 0
    fi

    # Back up ~/.zshrc
    local backup="$ZSHRC.backup.$(date +%Y%m%d%H%M%S)"
    cp "$ZSHRC" "$backup"
    echo "Backed up $ZSHRC to $backup"

    if ! grep -qF "$END_MARKER" "$ZSHRC"; then
        echo "Error: Could not find '$END_MARKER' in $ZSHRC."
        echo "Please add the clauden function manually."
        return 1
    fi

    # Insert clauden function before the end marker
    local tmpfile
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
}

# ── Part 2: Notification hook in ~/.claude/settings.json ─────────────

install_notification_hook() {
    if [ ! -f "$SETTINGS" ]; then
        echo "Creating $SETTINGS"
        mkdir -p "$(dirname "$SETTINGS")"
        echo '{}' > "$SETTINGS"
    fi

    # Check if Notification hook already exists
    if python3 -c "
import json, sys
with open('$SETTINGS') as f:
    data = json.load(f)
sys.exit(0 if data.get('hooks', {}).get('Notification') else 1)
" 2>/dev/null; then
        echo "Notification hook already exists in $SETTINGS — skipping."
        return 0
    fi

    # Back up settings
    local backup="$SETTINGS.backup.$(date +%Y%m%d%H%M%S)"
    cp "$SETTINGS" "$backup"
    echo "Backed up $SETTINGS to $backup"

    # Merge the Notification hook into existing settings
    python3 -c "
import json

with open('$SETTINGS') as f:
    data = json.load(f)

data.setdefault('hooks', {})
data['hooks']['Notification'] = [
    {
        'matcher': '',
        'hooks': [
            {
                'type': 'command',
                'command': 'osascript -e \'display notification \"Claude Code needs your attention\" with title \"Needs Input\" sound name \"Glass\"\'',
            }
        ],
    }
]

with open('$SETTINGS', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"
    echo "Added Notification hook to $SETTINGS"
}

# ── Run ──────────────────────────────────────────────────────────────

install_clauden
install_notification_hook

echo ""
echo "Done! Two notification sources configured:"
echo "  1. clauden wrapper  — notifies when a task completes or fails"
echo "  2. Notification hook — notifies when Claude needs your input"
echo ""
echo "Next steps:"
echo "  Run: source ~/.zshrc"
echo "  Or open a new terminal window."
echo ""
echo "Usage: clauden \"your task here\""
