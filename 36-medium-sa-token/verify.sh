#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-sa-token"
COURSE_DIR="/tmp/ckad-sa-token"
PASS=0
FAIL=0
TOTAL=3

echo "=== Verifying Exercise 36: Decode a ServiceAccount Token ==="
echo ""

# Check 1: file exists and is non-empty
echo -n "Check 1/3 - $COURSE_DIR/token exists and is non-empty: "
if [ -s "$COURSE_DIR/token" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (file missing or empty)"
  FAIL=$((FAIL + 1))
fi

# Check 2: file content matches the decoded secret token
echo -n "Check 2/3 - file content matches the decoded Secret token: "
EXPECTED=$(kubectl get secret backend-sa-v2-token -n "$NAMESPACE" -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null) || EXPECTED=""
ACTUAL=$(cat "$COURSE_DIR/token" 2>/dev/null || true)
# Strip any trailing newline differences
if [ -n "$EXPECTED" ] && [ "$(printf '%s' "$ACTUAL" | tr -d '\n')" = "$(printf '%s' "$EXPECTED" | tr -d '\n')" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (content does not match decoded token)"
  FAIL=$((FAIL + 1))
fi

# Check 3: file is decoded (a JWT, not base64 of a JWT)
echo -n "Check 3/3 - token is decoded (looks like a JWT): "
ACTUAL=$(cat "$COURSE_DIR/token" 2>/dev/null | tr -d '\n' || true)
if printf '%s' "$ACTUAL" | grep -q '^eyJ'; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (expected a decoded JWT starting with 'eyJ' — did you forget base64 -d?)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
