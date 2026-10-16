#!/bin/bash
# Launch the CKAD exercises TUI.
# Builds the binary on first run, then starts the interactive interface.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TUI_DIR="$ROOT/tui"
BIN="$TUI_DIR/ckad-tui"

if [ ! -x "$BIN" ] || [ "$TUI_DIR/model.go" -nt "$BIN" ] || [ "$TUI_DIR/exercises.go" -nt "$BIN" ] || [ "$TUI_DIR/main.go" -nt "$BIN" ]; then
  echo "Building TUI..."
  (cd "$TUI_DIR" && go build -o ckad-tui ./...)
fi

exec "$BIN" "$ROOT"
