#!/usr/bin/env bash
# zmsgh — poke your friend's screen over Tailscale SSH using zques
# Usage: zmsgh <type> <text> [options...]
#
# Fires a zques dialog on duck@pcduck's desktop.
# Their response is printed back to YOUR terminal.

set -euo pipefail

FRIEND_HOST="duck@pcduck"
FRIEND_LIB="/usr/local/lib/zques_lib.sh"
WINDOW_TITLE="🐦 Hey!"

# ─── Help ────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") <type> <text> [options...]

Pops a dialog on $FRIEND_HOST's screen and shows you their response.

Arguments:
  <type>     Any zques dialog type
  <text>     Message to show your friend
  [options]  Extra options for list/checklist/radiolist/combo/scale

Examples:
  zmsgh info "WAKE UP I WANNA PLAY WITH YOU"
  zmsgh question "Wanna play?"
  zmsgh list "What game?" Minecraft Terraria "Deep Rock Galactic"
  zmsgh entry "What time works for you?"
  zmsgh scale "Rate your mood:" 1 10 1 5

Your friend needs:
  - zques_lib.sh at $FRIEND_LIB
  - A running display (DISPLAY=:0)
EOF
  exit 1
}

[[ $# -lt 2 ]] && usage

TYPE="$1"
TEXT="$2"
shift 2
OPTIONS=("$@")

# ─── Build the remote command ─────────────────────────────────────────────────
# We source the lib remotely and call zques_dialog directly — no zques binary needed
REMOTE_CMD=$(cat <<REMOTE
export DISPLAY=:0
source "$FRIEND_LIB"
zques_dialog $(printf '%q ' "$WINDOW_TITLE" "$TYPE" "$TEXT" "${OPTIONS[@]}")
REMOTE
)

# ─── Fire it over SSH and relay the response ──────────────────────────────────
echo "→ Poking $FRIEND_HOST..."
RESPONSE=$(ssh "$FRIEND_HOST" "$REMOTE_CMD" 2>/dev/null) || {
  echo "Error: Could not reach $FRIEND_HOST. Are they online on Tailscale?" >&2
  exit 1
}

echo "← $FRIEND_HOST says: ${RESPONSE#The user selected: }"
