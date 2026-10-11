#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-sa"
PASS=0
FAIL=0
TOTAL=5

echo "=== Verifying Exercise 23: ServiceAccount Configuration ==="
echo ""

# Check 1: ServiceAccount exists
echo -n "1. ServiceAccount 'app-sa' exists: "
if kubectl get serviceaccount app-sa -n "$NAMESPACE" &>/dev/null; then
  echo "PASS"
  ((PASS++))
else
  echo "FAIL"
  ((FAIL++))
fi

# Check 2: Pod exists and is Running
echo -n "2. Pod 'sa-pod' exists and is Running: "
PHASE=$(kubectl get pod sa-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [[ "$PHASE" == "Running" ]]; then
  echo "PASS"
  ((PASS++))
else
  echo "FAIL (phase: '$PHASE')"
  ((FAIL++))
fi

# Check 3: Pod uses ServiceAccount app-sa
echo -n "3. Pod uses ServiceAccount 'app-sa': "
SA=$(kubectl get pod sa-pod -n "$NAMESPACE" -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null || true)
if [[ "$SA" == "app-sa" ]]; then
  echo "PASS"
  ((PASS++))
else
  echo "FAIL (got: '$SA')"
  ((FAIL++))
fi

# Check 4: automountServiceAccountToken is false
echo -n "4. automountServiceAccountToken is false: "
VAL=$(kubectl get pod sa-pod -n "$NAMESPACE" -o jsonpath='{.spec.automountServiceAccountToken}' 2>/dev/null || true)
if [[ "$VAL" == "false" ]]; then
  echo "PASS"
  ((PASS++))
else
  echo "FAIL (got: '$VAL')"
  ((FAIL++))
fi

# Check 5: No service account token mounted
echo -n "5. No service account token mounted in container: "
TOKEN_CHECK=$(kubectl exec sa-pod -n "$NAMESPACE" -- ls /var/run/secrets/kubernetes.io/serviceaccount 2>&1 || true)
if echo "$TOKEN_CHECK" | grep -qi "no such file\|cannot access\|not found"; then
  echo "PASS"
  ((PASS++))
else
  # Also check if directory is empty
  FILE_COUNT=$(kubectl exec sa-pod -n "$NAMESPACE" -- ls /var/run/secrets/kubernetes.io/serviceaccount 2>/dev/null | wc -l || echo "0")
  if [[ "$FILE_COUNT" -eq 0 ]]; then
    echo "PASS"
    ((PASS++))
  else
    echo "FAIL (token appears to be mounted)"
    ((FAIL++))
  fi
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
