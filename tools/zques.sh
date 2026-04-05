#!/usr/bin/env bash
# zques — zenity dialog CLI
# Usage: zques <title> <type> <text> [options...]
# Requires: /usr/local/lib/zques_lib.sh

set -euo pipefail

ZQUES_LIB="/usr/local/lib/zques_lib.sh"

if [[ ! -f "$ZQUES_LIB" ]]; then
  echo "Error: zques library not found at $ZQUES_LIB" >&2
  echo "Install it with: sudo cp zques_lib.sh $ZQUES_LIB" >&2
  exit 1
fi

source "$ZQUES_LIB"

# ─── Help ────────────────────────────────────────────────────────────────────
usage() {
  cat <<HELP
Usage: $(basename "$0") <title> <type> <text> [options...]

Arguments:
  <title>    Window title
  <type>     Dialog type (see below)
  <text>     Message / prompt shown in the dialog
  [options]  Extra arguments required by certain types

Dialog types
────────────
  Simple (no options):
    info        Informational message
    warning     Warning message
    error       Error message
    question    Yes / No prompt
    entry       Free-text input box
    progress    Progress bar
    calendar    Date picker
    color       Color picker

  With options:
    list        Pick one    → zques <title> list <text> opt1 opt2 ...
    checklist   Pick many   → zques <title> checklist <text> opt1 opt2 ...
    radiolist   Pick one    → zques <title> radiolist <text> opt1 opt2 ...
    combo       Dropdown    → zques <title> combo <text> opt1 opt2 ...
    scale       Slider      → zques <title> scale <text> <min> <max> [step] [default]

Examples:
  zques "Alert" info "Everything is fine."
  zques "Confirm" question "Delete this file?"
  zques "Pick" list "Choose a fruit:" Apple Banana Cherry
  zques "Volume" scale "Set volume:" 0 100 1 50
HELP
  exit 1
}

[[ $# -lt 3 ]] && usage

zques_dialog "$@"
