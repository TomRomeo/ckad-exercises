#!/bin/bash
set -euo pipefail

NS="ckad-svc-clusterip"
PASS=0
FAIL=0
TOTAL=5

echo "=== Verifying Exercise 26: ClusterIP Service ==="
echo ""

# Check 1: Service exists
echo -n "Check 1/5 - Service 'backend-svc' exists: "
if kubectl get service backend-svc -n "$NS" 2>/dev/null >&2; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Service 'backend-svc' not found in namespace '$NS'"
  FAIL=$((FAIL + 1))
fi

# Check 2: Service type is ClusterIP
echo -n "Check 2/5 - Service type is ClusterIP: "
SVC_TYPE=$(kubectl get service backend-svc -n "$NS" -o jsonpath='{.spec.type}' 2>/dev/null || echo "")
if [ "$SVC_TYPE" = "ClusterIP" ] || [ -z "$SVC_TYPE" ]; then
  # Empty type also means ClusterIP (it's the default)
  ACTUAL_TYPE=$(kubectl get service backend-svc -n "$NS" -o jsonpath='{.spec.type}' 2>/dev/null || echo "NOT_FOUND")
  if [ "$ACTUAL_TYPE" = "NOT_FOUND" ]; then
    echo "FAIL - Service not found"
    FAIL=$((FAIL + 1))
  else
    echo "PASS"
    PASS=$((PASS + 1))
  fi
else
  echo "FAIL - Expected 'ClusterIP', got '$SVC_TYPE'"
  FAIL=$((FAIL + 1))
fi

# Check 3: Service port is 80 and targetPort is 80
echo -n "Check 3/5 - Service port=80, targetPort=80: "
SVC_PORT=$(kubectl get service backend-svc -n "$NS" -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || echo "")
SVC_TARGET_PORT=$(kubectl get service backend-svc -n "$NS" -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null || echo "")
if [ "$SVC_PORT" = "80" ] && [ "$SVC_TARGET_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - port='$SVC_PORT' (expected 80), targetPort='$SVC_TARGET_PORT' (expected 80)"
  FAIL=$((FAIL + 1))
fi

# Check 4: Selector is app=backend
echo -n "Check 4/5 - Selector is app=backend: "
SELECTOR=$(kubectl get service backend-svc -n "$NS" -o jsonpath='{.spec.selector.app}' 2>/dev/null || echo "")
if [ "$SELECTOR" = "backend" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected selector app=backend, got app='$SELECTOR'"
  FAIL=$((FAIL + 1))
fi

# Check 5: Service has 2 endpoints
echo -n "Check 5/5 - Service has 2 endpoints: "
ENDPOINT_COUNT=$(kubectl get endpoints backend-svc -n "$NS" -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o '"ip"' | wc -l | tr -d ' ')
if [ "$ENDPOINT_COUNT" = "2" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected 2 endpoints, found $ENDPOINT_COUNT"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
