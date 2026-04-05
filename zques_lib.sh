#!/usr/bin/env bash
# zques_lib.sh — core library for zenity dialogs
# Source this file; do NOT execute it directly.
#
# Public function:
#   zques_dialog <title> <type> <text> [options...]
#
# Returns: prints "The user selected: <value>" to stdout

# ─── Dependency check ────────────────────────────────────────────────────────
_zques_check_deps() {
  if ! command -v zenity &>/dev/null; then
    echo "Error: 'zenity' is not installed." >&2
    echo "  sudo apt install zenity    (Debian/Ubuntu)" >&2
    echo "  sudo dnf install zenity    (Fedora/RHEL)"   >&2
    return 127
  fi
}

# ─── Output helper ───────────────────────────────────────────────────────────
_zques_selected() { echo "The user selected: $*"; }

# ─── Require N options or bail ───────────────────────────────────────────────
_zques_require_options() {
  local min="$1" label="$2" count="$3"
  if [[ $count -lt $min ]]; then
    echo "Error: '$ZQUES_TYPE' requires at least $min option(s) after <text>. Got $count." >&2
    return 2
  fi
}

# ─── Main dialog function ─────────────────────────────────────────────────────
# Usage: zques_dialog <title> <type> <text> [options...]
zques_dialog() {
  _zques_check_deps || return $?

  if [[ $# -lt 3 ]]; then
    echo "Error: zques_dialog requires at least 3 arguments: <title> <type> <text>" >&2
    return 1
  fi

  local TITLE="$1"
  local ZQUES_TYPE="${2,,}"
  local TEXT="$3"
  shift 3
  local OPTIONS=("$@")
  local WIDTH=400
  local RESULT

  # Silence zenity GTK noise
  exec 2>/dev/null

  case "$ZQUES_TYPE" in

    info)
      if zenity --info --title="$TITLE" --text="$TEXT" --width=$WIDTH; then
        _zques_selected "OK"
      else
        _zques_selected "Dismissed (×)"
      fi
      ;;

    warning)
      if zenity --warning --title="$TITLE" --text="$TEXT" --width=$WIDTH; then
        _zques_selected "OK"
      else
        _zques_selected "Dismissed (×)"
      fi
      ;;

    error)
      if zenity --error --title="$TITLE" --text="$TEXT" --width=$WIDTH; then
        _zques_selected "OK"
      else
        _zques_selected "Dismissed (×)"
      fi
      ;;

    question)
      if zenity --question --title="$TITLE" --text="$TEXT" --width=$WIDTH; then
        _zques_selected "Yes"
      else
        _zques_selected "No"
      fi
      ;;

    entry)
      RESULT=$(zenity --entry --title="$TITLE" --text="$TEXT" --width=$WIDTH) \
        && _zques_selected "$RESULT" \
        || _zques_selected "Dismissed (×)"
      ;;

    progress)
      (
        for i in $(seq 0 5 100); do echo "$i"; sleep 0.08; done
      ) | zenity --progress \
            --title="$TITLE" --text="$TEXT" \
            --percentage=0 --auto-close --width=$WIDTH \
        && _zques_selected "Completed" \
        || _zques_selected "Cancelled"
      ;;

    calendar)
      RESULT=$(zenity --calendar --title="$TITLE" --text="$TEXT" --width=$WIDTH) \
        && _zques_selected "$RESULT" \
        || _zques_selected "Dismissed (×)"
      ;;

    color)
      RESULT=$(zenity --color-selection --title="$TITLE" --show-palette) \
        && _zques_selected "$RESULT" \
        || _zques_selected "Dismissed (×)"
      ;;

    list)
      _zques_require_options 1 "opt1 opt2 ..." "${#OPTIONS[@]}" || return $?
      local ROWS=()
      for opt in "${OPTIONS[@]}"; do ROWS+=("$opt"); done
      RESULT=$(zenity --list \
        --title="$TITLE" --text="$TEXT" \
        --column="Option" \
        --width=$WIDTH --height=350 \
        "${ROWS[@]}") \
        && _zques_selected "$RESULT" \
        || _zques_selected "Dismissed (×)"
      ;;

    checklist)
      _zques_require_options 1 "opt1 opt2 ..." "${#OPTIONS[@]}" || return $?
      local ROWS=()
      for opt in "${OPTIONS[@]}"; do ROWS+=(FALSE "$opt"); done
      RESULT=$(zenity --list \
        --checklist \
        --title="$TITLE" --text="$TEXT" \
        --column="✔" --column="Option" \
        --width=$WIDTH --height=350 \
        "${ROWS[@]}") \
        && _zques_selected "$(echo "$RESULT" | tr '|' ', ')" \
        || _zques_selected "Dismissed (×)"
      ;;

    radiolist)
      _zques_require_options 1 "opt1 opt2 ..." "${#OPTIONS[@]}" || return $?
      local ROWS=()
      for opt in "${OPTIONS[@]}"; do ROWS+=(FALSE "$opt"); done
      ROWS[0]=TRUE
      RESULT=$(zenity --list \
        --radiolist \
        --title="$TITLE" --text="$TEXT" \
        --column="◉" --column="Option" \
        --width=$WIDTH --height=350 \
        "${ROWS[@]}") \
        && _zques_selected "$RESULT" \
        || _zques_selected "Dismissed (×)"
      ;;

    combo)
      _zques_require_options 1 "opt1 opt2 ..." "${#OPTIONS[@]}" || return $?
      local COMBO_ARGS=()
      for opt in "${OPTIONS[@]}"; do COMBO_ARGS+=(--entry-text="$opt"); done
      RESULT=$(zenity --entry \
        --title="$TITLE" --text="$TEXT" \
        --width=$WIDTH \
        "${COMBO_ARGS[@]}") \
        && _zques_selected "$RESULT" \
        || _zques_selected "Dismissed (×)"
      ;;

    scale)
      _zques_require_options 2 "<min> <max> [step] [default]" "${#OPTIONS[@]}" || return $?
      local MIN="${OPTIONS[0]}" MAX="${OPTIONS[1]}"
      local STEP="${OPTIONS[2]:-1}" DEFAULT="${OPTIONS[3]:-${OPTIONS[0]}}"
      RESULT=$(zenity --scale \
        --title="$TITLE" --text="$TEXT" \
        --min-value="$MIN" --max-value="$MAX" \
        --step="$STEP" --value="$DEFAULT" \
        --width=$WIDTH) \
        && _zques_selected "$RESULT" \
        || _zques_selected "Dismissed (×)"
      ;;

    *)
      echo "Error: Unknown dialog type '$ZQUES_TYPE'." >&2
      return 2
      ;;

  esac
}
