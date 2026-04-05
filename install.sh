#!/usr/bin/env bash
# install.sh — ztools installer
# Usage: sudo ./install.sh [uninstall|reinstall]

set -euo pipefail

LIB_DIR="/usr/local/lib"
BIN_DIR="/usr/local/bin"

LIB="libs/zques_lib.sh"
TOOLS=("tools/zques.sh" "tools/zmsgh.sh")
TOOL_NAMES=("zques" "zmsgh")

# ─── Must run as root ─────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root: sudo ./install.sh"
  exit 1
fi

# ─── Must run from repo root ──────────────────────────────────────────────────
if [[ ! -f "$LIB" ]]; then
  echo "Error: Run this script from the root of the ztools repo." >&2
  exit 1
fi

# ─── Uninstall function ───────────────────────────────────────────────────────
uninstall() {
  echo "Uninstalling ztools..."
  rm -f "$LIB_DIR/zques_lib.sh"
  for name in "${TOOL_NAMES[@]}"; do
    rm -f "$BIN_DIR/$name"
  done
  echo "✔ ztools has been removed."
}

# ─── Install function ─────────────────────────────────────────────────────────
install() {
  # Check zenity
  if ! command -v zenity &>/dev/null; then
    echo "Warning: 'zenity' is not installed."
    echo "  sudo apt install zenity    (Debian/Ubuntu)"
    echo "  sudo dnf install zenity    (Fedora/RHEL)"
    echo ""
  fi

  echo "Installing library → $LIB_DIR/zques_lib.sh"
  cp "$LIB" "$LIB_DIR/zques_lib.sh"
  chmod 644 "$LIB_DIR/zques_lib.sh"

  for i in "${!TOOLS[@]}"; do
    src="${TOOLS[$i]}"
    name="${TOOL_NAMES[$i]}"
    echo "Installing tool    → $BIN_DIR/$name"
    cp "$src" "$BIN_DIR/$name"
    chmod +x "$BIN_DIR/$name"
  done

  echo ""
  echo "✔ ztools installed successfully!"
  echo ""
  echo "  zques  – show a dialog locally"
  echo "  zmsgh  – send a dialog to a friend over SSH"
  echo ""
  echo "To uninstall:  sudo ./install.sh uninstall"
  echo "To reinstall:  sudo ./install.sh reinstall"
}

# ─── Dispatch ─────────────────────────────────────────────────────────────────
case "${1:-}" in
  uninstall)
    uninstall
    ;;
  reinstall)
    echo "Reinstalling ztools..."
    uninstall
    echo ""
    install
    ;;
  "")
    install
    ;;
  *)
    echo "Usage: sudo ./install.sh [uninstall|reinstall]" >&2
    exit 1
    ;;
esac
