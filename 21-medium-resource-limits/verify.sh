#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-resources"
PASS=0
FAIL=0
TOTAL=10

echo "=== Verifying Exercise 21: Resource Requests and Limits ==="
echo ""

# Check 1: resource-pod exists and is Running
echo -n "1. Pod 'resource-pod' exists and is Running: "
PHASE=$(kubectl get pod resource-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [[ "$PHASE" == "Running" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (phase: '$PHASE')"
  FAIL=$((FAIL + 1))
fi

# Check 2: resource-pod requests cpu=100m
echo -n "2. resource-pod requests cpu=100m: "
VAL=$(kubectl get pod resource-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="web")].resources.requests.cpu}' 2>/dev/null || true)
if [[ "$VAL" == "100m" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 3: resource-pod requests memory=128Mi
echo -n "3. resource-pod requests memory=128Mi: "
VAL=$(kubectl get pod resource-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="web")].resources.requests.memory}' 2>/dev/null || true)
if [[ "$VAL" == "128Mi" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 4: resource-pod limits cpu=250m
echo -n "4. resource-pod limits cpu=250m: "
VAL=$(kubectl get pod resource-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="web")].resources.limits.cpu}' 2>/dev/null || true)
if [[ "$VAL" == "250m" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 5: resource-pod limits memory=256Mi
echo -n "5. resource-pod limits memory=256Mi: "
VAL=$(kubectl get pod resource-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="web")].resources.limits.memory}' 2>/dev/null || true)
if [[ "$VAL" == "256Mi" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 6: resource-pod-2 exists and is Running
echo -n "6. Pod 'resource-pod-2' exists and is Running: "
PHASE=$(kubectl get pod resource-pod-2 -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [[ "$PHASE" == "Running" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (phase: '$PHASE')"
  FAIL=$((FAIL + 1))
fi

# Check 7: resource-pod-2 requests cpu=50m
echo -n "7. resource-pod-2 requests cpu=50m: "
VAL=$(kubectl get pod resource-pod-2 -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="worker")].resources.requests.cpu}' 2>/dev/null || true)
if [[ "$VAL" == "50m" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 8: resource-pod-2 requests memory=64Mi
echo -n "8. resource-pod-2 requests memory=64Mi: "
VAL=$(kubectl get pod resource-pod-2 -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="worker")].resources.requests.memory}' 2>/dev/null || true)
if [[ "$VAL" == "64Mi" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 9: resource-pod-2 limits cpu=100m
echo -n "9. resource-pod-2 limits cpu=100m: "
VAL=$(kubectl get pod resource-pod-2 -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="worker")].resources.limits.cpu}' 2>/dev/null || true)
if [[ "$VAL" == "100m" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 10: resource-pod-2 limits memory=128Mi
echo -n "10. resource-pod-2 limits memory=128Mi: "
VAL=$(kubectl get pod resource-pod-2 -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="worker")].resources.limits.memory}' 2>/dev/null || true)
if [[ "$VAL" == "128Mi" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
