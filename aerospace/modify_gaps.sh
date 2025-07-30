#!/bin/bash

# --- Configuration ---
STEP=8
DEFAULT_INNER=6
DEFAULT_OUTER=6
CONFIG_FILE="$HOME/.config/aerospace/aerospace.toml"
# ---------------------

# Create a temporary file to store changes
TMP_FILE=$(mktemp)

# Ensure the temporary file is removed on exit
trap 'rm -f "$TMP_FILE"' EXIT

while IFS= read -r line || [[ -n "$line" ]]; do
  # Check if the line is a configurable gap setting
  if [[ $line =~ ^[[:space:]]*(inner\.(horizontal|vertical))[[:space:]]*=[[:space:]]*(-?[0-9]+)[[:space:]]*$ ]]; then
    key="${BASH_REMATCH[1]}"
    current_val="${BASH_REMATCH[3]}"
    new_val=$current_val

    case "$1" in
      up)
        new_val=$((current_val + STEP))
        ;;
      down)
        new_val=$((current_val - STEP))
        # [ $new_val -lt 0 ] && new_val=0
        ;;
      reset)
        if [[ $key == inner* ]]; then
          new_val=$DEFAULT_INNER
        else
          new_val=$DEFAULT_OUTER
        fi
        ;;
      *)
        # On invalid argument, script will exit later
        ;;
    esac
    echo "$key = $new_val" >> "$TMP_FILE"
  else
    # Copy non-gap lines as-is
    echo "$line" >> "$TMP_FILE"
  fi
done < "$CONFIG_FILE"

# Validate argument before overwriting the original file
case "$1" in
  up|down|reset)
    # Argument is valid, proceed to replace the config file
    mv "$TMP_FILE" "$CONFIG_FILE"
    ;;
  *)
    echo "Usage: $0 [up|down|reset]"
    exit 1
    ;;
esac

aerospace reload-config
