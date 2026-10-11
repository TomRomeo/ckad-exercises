#!/bin/bash
set -euo pipefail

SRC_NS="ckad-staging"
DST_NS="ckad-shop"
PASS=0
FAIL=0
TOTAL=4

echo "=== Verifying Exercise 37: Find a Pod by Label and Move It ==="
echo ""

# Check 1: a pod with the label exists in target namespace
echo -n "Check 1/4 - a pod labelled system=web-shop exists in $DST_NS: "
DST_POD=$(kubectl get pods -n "$DST_NS" -l system=web-shop -o jsonpath='{.items[0].metadata.name}' 2>/dev/null) || DST_POD=""
if [ -n "$DST_POD" ]; then
  echo "PASS (found '$DST_POD')"
  PASS=$((PASS + 1))
else
  echo "FAIL (no matching pod in $DST_NS)"
  FAIL=$((FAIL + 1))
fi

# Check 2: that pod is Running
echo -n "Check 2/4 - the moved pod is Running: "
if [ -n "$DST_POD" ]; then
  PHASE=$(kubectl get pod "$DST_POD" -n "$DST_NS" -o jsonpath='{.status.phase}' 2>/dev/null) || PHASE=""
else
  PHASE=""
fi
if [ "$PHASE" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: '${PHASE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: image matches the original (httpd:2-alpine)
echo -n "Check 3/4 - moved pod uses the original image httpd:2-alpine: "
if [ -n "$DST_POD" ]; then
  IMG=$(kubectl get pod "$DST_POD" -n "$DST_NS" -o jsonpath='{.spec.containers[0].image}' 2>/dev/null) || IMG=""
else
  IMG=""
fi
if [ "$IMG" = "httpd:2-alpine" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (image: '${IMG:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: original is gone from source namespace
echo -n "Check 4/4 - no pod labelled system=web-shop remains in $SRC_NS: "
SRC_LEFT=$(kubectl get pods -n "$SRC_NS" -l system=web-shop -o jsonpath='{.items[*].metadata.name}' 2>/dev/null) || SRC_LEFT=""
if [ -z "$SRC_LEFT" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (still present in $SRC_NS: '$SRC_LEFT')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
