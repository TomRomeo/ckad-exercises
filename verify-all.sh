#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo "  CKAD Exercise Verification - All Exercises"
echo "============================================"
echo ""

TOTAL_EXERCISES=0
PASSED_EXERCISES=0
FAILED_EXERCISES=0
SKIPPED_EXERCISES=0

RESULTS=()

for dir in "$SCRIPT_DIR"/*/; do
    exercise="$(basename "$dir")"
    if [[ ! -f "$dir/verify.sh" ]]; then
        continue
    fi

    TOTAL_EXERCISES=$((TOTAL_EXERCISES + 1))
    echo "=== Verifying: $exercise ==="

    set +e
    output=$(bash "$dir/verify.sh" 2>&1)
    exit_code=$?
    set -e

    echo "$output" | sed 's/^/  /'
    echo ""

    if [[ $exit_code -eq 0 ]]; then
        PASSED_EXERCISES=$((PASSED_EXERCISES + 1))
        RESULTS+=("PASS  $exercise")
    else
        FAILED_EXERCISES=$((FAILED_EXERCISES + 1))
        RESULTS+=("FAIL  $exercise")
    fi
done

echo ""
echo "============================================"
echo "  CKAD Exercise Results Summary"
echo "============================================"
echo ""

for result in "${RESULTS[@]}"; do
    if [[ "$result" == PASS* ]]; then
        echo "  ✓ ${result#PASS  }"
    else
        echo "  ✗ ${result#FAIL  }"
    fi
done

echo ""
echo "--------------------------------------------"

PERCENTAGE=0
if [[ $TOTAL_EXERCISES -gt 0 ]]; then
    PERCENTAGE=$(( (PASSED_EXERCISES * 100) / TOTAL_EXERCISES ))
fi

echo "  Total:  $TOTAL_EXERCISES exercises"
echo "  Passed: $PASSED_EXERCISES"
echo "  Failed: $FAILED_EXERCISES"
echo "  Score:  ${PERCENTAGE}%"
echo ""

# CKAD passing score is 66%
if [[ $PERCENTAGE -ge 66 ]]; then
    echo "  >> RESULT: PASS (>= 66% required) <<"
else
    echo "  >> RESULT: FAIL (>= 66% required) <<"
fi
echo "============================================"

exit $FAILED_EXERCISES
