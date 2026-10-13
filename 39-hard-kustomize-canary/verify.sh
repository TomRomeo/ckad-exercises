#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-kustomize"
PASS=0
FAIL=0
TOTAL=4

echo "=== Verifying Exercise 39: Canary Rollout with Kustomize ==="
echo ""

# Check 1: web-main has 8 replicas (spec)
echo -n "Check 1/4 - web-main spec.replicas is 8: "
MAIN=$(kubectl get deploy web-main -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null) || MAIN=""
if [ "$MAIN" = "8" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (web-main replicas: '${MAIN:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: web-canary has 2 replicas (spec)
echo -n "Check 2/4 - web-canary spec.replicas is 2: "
CAN=$(kubectl get deploy web-canary -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null) || CAN=""
if [ "$CAN" = "2" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (web-canary replicas: '${CAN:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: total ready pods across both tracks is 10
echo -n "Check 3/4 - total of 10 pods running for app=web: "
RUNNING=$(kubectl get pods -n "$NAMESPACE" -l app=web --field-selector=status.phase=Running --no-headers 2>/dev/null | grep -c . || true)
if [ "${RUNNING:-0}" = "10" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (running app=web pods: '${RUNNING:-0}', expected 10 — give pods a moment to start)"
  FAIL=$((FAIL + 1))
fi

# Check 4: Service web-svc exists and is still a ClusterIP (unchanged)
echo -n "Check 4/4 - Service web-svc exists and is ClusterIP (unchanged): "
if kubectl get svc web-svc -n "$NAMESPACE" >/dev/null 2>&1; then
  STYPE=$(kubectl get svc web-svc -n "$NAMESPACE" -o jsonpath='{.spec.type}' 2>/dev/null) || STYPE=""
  if [ "$STYPE" = "ClusterIP" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL (web-svc type changed to: '${STYPE:-unknown}')"
    FAIL=$((FAIL + 1))
  fi
else
  echo "FAIL (web-svc not found — did you apply the Kustomize dir?)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
