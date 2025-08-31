#!/bin/bash

# Toggle background opacity between 0.85 and 1 in Ghostty config

CONFIG_FILE="$HOME/.dotfiles/ghostty/config"

# Get current background-opacity value
current_opacity=$(grep "^background-opacity" "$CONFIG_FILE" | cut -d'=' -f2 | tr -d ' ')

# Toggle between 0.85 and 1
if [ "$current_opacity" = "0.85" ]; then
    new_opacity="1"
else
    new_opacity="0.85"
fi

# Update the config file
sed -i '' "s/^background-opacity = .*/background-opacity = $new_opacity/" "$CONFIG_FILE"

echo "Background opacity changed to $new_opacity"

 # Ensure Ghostty reloads config by sending Cmd-Shift-,
if command -v osascript >/dev/null 2>&1; then
    /usr/bin/osascript <<'OSA'
tell application "Ghostty" to activate
delay 0.05
tell application "System Events" to keystroke "," using {command down, shift down}
OSA
fi
