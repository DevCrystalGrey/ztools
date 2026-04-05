#!/usr/bin/env bash
# zmsgh — poke your friend's screen over Tailscale SSH using zques
# Usage: zmsgh <host> <type> <text> [options...]

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
  - A running display
HELP
  exit 1
}

[[ $# -lt 3 ]] && usage

FRIEND_HOST="$1"
TYPE="$2"
TEXT="$3"
shift 3
OPTIONS=("$@")

# ─── Detect remote display ────────────────────────────────────────────────────
REMOTE_DISPLAY=$(ssh "$FRIEND_HOST" "who | grep -oP '\(:\d+\)' | head -1 | tr -d '()'" 2>/dev/null)
REMOTE_DISPLAY="${REMOTE_DISPLAY:-:0}"

# ─── Build args as a JSON-like escaped string passed via env var ──────────────
# Pass each argument as a separate env var to avoid quoting hell
echo "→ Poking $FRIEND_HOST... (display: $REMOTE_DISPLAY)"

RESPONSE=$(ssh "$FRIEND_HOST" \
  "DISPLAY=$REMOTE_DISPLAY" \
  "ZQUES_TITLE=$(printf '%q' "$WINDOW_TITLE")" \
  "ZQUES_TYPE=$(printf '%q' "$TYPE")" \
  "ZQUES_TEXT=$(printf '%q' "$TEXT")" \
  "ZQUES_OPTS=$(printf '%q ' "${OPTIONS[@]}")" \
  bash << 'SSHSCRIPT'
source /usr/local/lib/zques_lib.sh
eval "zques_dialog '$ZQUES_TITLE' '$ZQUES_TYPE' '$ZQUES_TEXT' $ZQUES_OPTS"
SSHSCRIPT
) 2>/dev/null || {
  echo "Error: Could not reach $FRIEND_HOST. Are they online on Tailscale?" >&2
  exit 1
}

echo "← $FRIEND_HOST says: ${RESPONSE#The user selected: }"
