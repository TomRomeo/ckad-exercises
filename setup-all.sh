#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo "  CKAD Exercise Environment Setup"
echo "============================================"
echo ""

TOTAL=0
SUCCESS=0
FAILED=0

for dir in "$SCRIPT_DIR"/*/; do
    exercise="$(basename "$dir")"
    # Skip if no setup.sh
    if [[ ! -f "$dir/setup.sh" ]]; then
        continue
    fi

    TOTAL=$((TOTAL + 1))
    echo "--- Setting up: $exercise ---"
    if bash "$dir/setup.sh" 2>&1 | sed 's/^/  /'; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAILED=$((FAILED + 1))
        echo "  [ERROR] Setup failed for $exercise"
    fi
    echo ""
done

echo "============================================"
echo "  Setup Complete"
echo "  Total: $TOTAL | Success: $SUCCESS | Failed: $FAILED"
echo "============================================"
echo ""
echo "You can now work through the exercises."
echo "Each exercise folder contains a README.md with instructions."
echo "Run verify.sh in each folder to check your solution."

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
