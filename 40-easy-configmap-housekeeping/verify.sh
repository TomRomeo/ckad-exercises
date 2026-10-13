#!/bin/bash
set -euo pipefail

NS1="ckad-housekeeping1"
NS2="ckad-housekeeping2"
COURSE_DIR="/tmp/ckad-housekeeping"
PASS=0
FAIL=0
TOTAL=3

echo "=== Verifying Exercise 40: ConfigMap Housekeeping by Label ==="
echo ""

# Check 1: cf-count file contains the correct cache count (3)
echo -n "Check 1/3 - $COURSE_DIR/cf-count equals number of purpose=cache ConfigMaps in $NS1: "
EXPECTED=$(kubectl get cm -n "$NS1" -l purpose=cache --no-headers 2>/dev/null | grep -c . || true)
WRITTEN=$(tr -dc '0-9' < "$COURSE_DIR/cf-count" 2>/dev/null || true)
if [ -n "$WRITTEN" ] && [ "$WRITTEN" = "$EXPECTED" ]; then
  echo "PASS (count=$WRITTEN)"
  PASS=$((PASS + 1))
else
  echo "FAIL (file='${WRITTEN:-empty}', expected='$EXPECTED')"
  FAIL=$((FAIL + 1))
fi

# Check 2: no expired ConfigMaps remain in NS2
echo -n "Check 2/3 - no ConfigMaps labelled purpose=expired remain in $NS2: "
LEFT=$(kubectl get cm -n "$NS2" -l purpose=expired --no-headers 2>/dev/null | grep -c . || true)
if [ "${LEFT:-0}" = "0" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL ($LEFT expired ConfigMaps still present)"
  FAIL=$((FAIL + 1))
fi

# Check 3: active ConfigMaps in NS2 were NOT deleted
echo -n "Check 3/3 - active ConfigMaps in $NS2 are untouched: "
ACTIVE=$(kubectl get cm -n "$NS2" -l purpose=active --no-headers 2>/dev/null | grep -c . || true)
if [ "${ACTIVE:-0}" = "2" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (expected 2 active ConfigMaps, found ${ACTIVE:-0} — did you delete too much?)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
