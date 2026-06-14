#!/usr/bin/env bash
set -e

# @describe Get uncertainty items from CLAUDE.md
# @flag -u --uncertain    Extract items with '[ ]' status (default)
# @flag -p --partial       Extract items with '[/]' status
# @flag -v --verified      Extract items with '[x]' status
# @flag -w --waiting       Extract items with '[s]' status
# @flag -a --all          Extract items with any status
# @env LLM_OUTPUT=/dev/stdout The output path

main() {
  # Get the project directory and CLAUDE.md path
  local PROJECT_DIR="$(pwd)"
  local CLAUDE_PATH="$PROJECT_DIR/CLAUDE.md"

  # Check if CLAUDE.md exists
  if [[ ! -f "$CLAUDE_PATH" ]]; then
    echo "Error: CLAUDE.md not found in $PROJECT_DIR"
    exit 1
  fi

  # Determine pattern and message based on flags
  local PATTERN="\- \[ \]" # Default: uncertain items
  local MESSAGE="Finding uncertain items ([ ]):"

  if [[ "$argc_partial" -eq 1 ]]; then
    PATTERN="\- \[/\]"
    MESSAGE="Finding partially verified items ([/]):"
  elif [[ "$argc_verified" -eq 1 ]]; then
    PATTERN="\- \[x\]"
    MESSAGE="Finding verified items ([x]):"
  elif [[ "$argc_waiting" -eq 1 ]]; then
    PATTERN="\- \[s\]"
    MESSAGE="Finding items waiting for input ([s]):"
  elif [[ "$argc_all" -eq 1 ]]; then
    PATTERN="\- \[[x/s ]\]"
    MESSAGE="Finding all verification items:"
  fi

  echo "$MESSAGE"

  # Extract lines containing the specified pattern
  grep "$PATTERN" "$CLAUDE_PATH"

  # Add summary
  echo ""
  echo "Total items found: $(grep -c "$PATTERN" "$CLAUDE_PATH")" >$LLM_OUTPUT
}

eval "$(argc --argc-eval "$0" "$@")"