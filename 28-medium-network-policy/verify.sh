#!/bin/bash
set -euo pipefail

NS="ckad-netpol"
PASS=0
FAIL=0
TOTAL=6

echo "=== Verifying Exercise 28: Network Policy ==="
echo ""

# Check 1: NetworkPolicy exists
echo -n "Check 1/6 - NetworkPolicy 'db-policy' exists: "
if kubectl get networkpolicy db-policy -n "$NS" 2>/dev/null >&2; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - NetworkPolicy 'db-policy' not found in namespace '$NS'"
  FAIL=$((FAIL + 1))
fi

# Check 2: podSelector targets app=db
echo -n "Check 2/6 - podSelector targets app=db: "
POD_SELECTOR=$(kubectl get networkpolicy db-policy -n "$NS" -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null || echo "")
if [ "$POD_SELECTOR" = "db" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected podSelector app=db, got app='$POD_SELECTOR'"
  FAIL=$((FAIL + 1))
fi

# Check 3: Has ingress rule
echo -n "Check 3/6 - Has ingress rules defined: "
INGRESS_RULES=$(kubectl get networkpolicy db-policy -n "$NS" -o jsonpath='{.spec.ingress}' 2>/dev/null || echo "")
if [ -n "$INGRESS_RULES" ] && [ "$INGRESS_RULES" != "[]" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - No ingress rules found"
  FAIL=$((FAIL + 1))
fi

# Check 4: Ingress allows from pods with label app=api
echo -n "Check 4/6 - Ingress allows from pods with app=api: "
INGRESS_FROM=$(kubectl get networkpolicy db-policy -n "$NS" -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.app}' 2>/dev/null || echo "")
if [ "$INGRESS_FROM" = "api" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected ingress from app=api, got app='$INGRESS_FROM'"
  FAIL=$((FAIL + 1))
fi

# Check 5: Ingress port is 80
echo -n "Check 5/6 - Ingress port is 80: "
INGRESS_PORT=$(kubectl get networkpolicy db-policy -n "$NS" -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null || echo "")
if [ "$INGRESS_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected ingress port 80, got '$INGRESS_PORT'"
  FAIL=$((FAIL + 1))
fi

# Check 6: policyTypes includes Ingress
echo -n "Check 6/6 - policyTypes includes 'Ingress': "
POLICY_TYPES=$(kubectl get networkpolicy db-policy -n "$NS" -o jsonpath='{.spec.policyTypes}' 2>/dev/null || echo "")
if echo "$POLICY_TYPES" | grep -q "Ingress"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - policyTypes does not include 'Ingress': '$POLICY_TYPES'"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
