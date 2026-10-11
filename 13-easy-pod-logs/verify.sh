#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0
TOTAL=4

echo "=== Verifying Exercise 13: Pod Logs ==="
echo ""

# Check 1: Pod log-generator is Running
echo -n "Check 1: Pod 'log-generator' is Running... "
POD_STATUS=$(kubectl get pod log-generator -n ckad-logs -o jsonpath='{.status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [ "$POD_STATUS" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: $POD_STATUS)"
  FAIL=$((FAIL + 1))
fi

# Check 2: File /tmp/ckad-logs-output.txt exists
echo -n "Check 2: File /tmp/ckad-logs-output.txt exists... "
if [ -f /tmp/ckad-logs-output.txt ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (file not found)"
  FAIL=$((FAIL + 1))
fi

# Check 3: File contains at least one line with "INFO log-line"
echo -n "Check 3: File contains 'INFO log-line'... "
if [ -f /tmp/ckad-logs-output.txt ] && grep -q "INFO log-line" /tmp/ckad-logs-output.txt 2>/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (pattern 'INFO log-line' not found in file)"
  FAIL=$((FAIL + 1))
fi

# Check 4: File has at most 10 lines
echo -n "Check 4: File has at most 10 lines... "
if [ -f /tmp/ckad-logs-output.txt ]; then
  LINE_COUNT=$(wc -l < /tmp/ckad-logs-output.txt | tr -d ' ')
  if [ "$LINE_COUNT" -le 10 ]; then
    echo "PASS ($LINE_COUNT lines)"
    PASS=$((PASS + 1))
  else
    echo "FAIL ($LINE_COUNT lines, expected <= 10)"
    FAIL=$((FAIL + 1))
  fi
else
  echo "FAIL (file not found)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
