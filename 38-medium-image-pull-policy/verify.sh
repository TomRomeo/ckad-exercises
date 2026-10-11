#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-pullpolicy"
PASS=0
FAIL=0
TOTAL=3

echo "=== Verifying Exercise 38: Image Pull Policy and Graceful Termination ==="
echo ""

# Check 1: app container imagePullPolicy IfNotPresent
echo -n "Check 1/3 - app container imagePullPolicy is IfNotPresent: "
APP_POL=$(kubectl get deploy harvester -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[?(@.name=="app")].imagePullPolicy}' 2>/dev/null) || APP_POL=""
if [ "$APP_POL" = "IfNotPresent" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (app imagePullPolicy: '${APP_POL:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: sidecar container imagePullPolicy Never
echo -n "Check 2/3 - sidecar container imagePullPolicy is Never: "
SIDE_POL=$(kubectl get deploy harvester -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[?(@.name=="sidecar")].imagePullPolicy}' 2>/dev/null) || SIDE_POL=""
if [ "$SIDE_POL" = "Never" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (sidecar imagePullPolicy: '${SIDE_POL:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: terminationGracePeriodSeconds 60
echo -n "Check 3/3 - terminationGracePeriodSeconds is 60: "
GRACE=$(kubectl get deploy harvester -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.terminationGracePeriodSeconds}' 2>/dev/null) || GRACE=""
if [ "$GRACE" = "60" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (terminationGracePeriodSeconds: '${GRACE:-not set}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
