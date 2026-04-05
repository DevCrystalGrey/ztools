#!/usr/bin/env bash
# zmsgh — poke your friend's screen over Tailscale SSH using zques
# Usage: zmsgh <host> <type> <text> [options...]
#
# Fires a zques dialog on the target host's desktop.
# Their response is printed back to YOUR terminal.

set -euo pipefail

FRIEND_LIB="/usr/local/lib/zques_lib.sh"
WINDOW_TITLE="🐦 Hey!"

# ─── Help ────────────────────────────────────────────────────────────────────
usage() {
  cat <<HELP
Usage: $(basename "$0") <host> <type> <text> [options...]

Pops a dialog on a friend's screen over SSH and shows you their response.

Arguments:
  <host>     SSH target (e.g. duck@pcduck, user@hostname)
  <type>     Any zques dialog type
  <text>     Message to show your friend
  [options]  Extra options for list/checklist/radiolist/combo/scale

Examples:
  zmsgh duck@pcduck info "WAKE UP I WANNA PLAY WITH YOU"
  zmsgh duck@pcduck question "Wanna play?"
  zmsgh duck@pcduck list "What game?" Minecraft Terraria "Deep Rock Galactic"
  zmsgh duck@pcduck entry "What time works for you?"
  zmsgh duck@pcduck scale "Rate your mood:" 1 10 1 5

Your friend needs:
  - zques_lib.sh at $FRIEND_LIB
  - A running display (DISPLAY=:0)
HELP
  exit 1
}

[[ $# -lt 3 ]] && usage

FRIEND_HOST="$1"
TYPE="$2"
TEXT="$3"
shift 3
OPTIONS=("$@")

# ─── Build the remote command ─────────────────────────────────────────────────
REMOTE_CMD=$(cat <<REMOTE
export DISPLAY=:0
source "$FRIEND_LIB"
zques_dialog $(printf '%q ' "$WINDOW_TITLE" "$TYPE" "$TEXT" "${OPTIONS[@]}")
REMOTE
)

# ─── Fire it over SSH and relay the response ──────────────────────────────────
echo "→ Poking $FRIEND_HOST..."
RESPONSE=$(ssh "$FRIEND_HOST" "bash -c $(printf '%q' "$REMOTE_CMD")" 2>/dev/null) || {
  echo "Error: Could not reach $FRIEND_HOST. Are they online on Tailscale?" >&2
  exit 1
}

echo "← $FRIEND_HOST says: ${RESPONSE#The user selected: }"
