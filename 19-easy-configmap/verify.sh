#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-configmap"
PASS=0
FAIL=0
TOTAL=7

echo "=== Verifying Exercise 19: ConfigMap Basics ==="
echo ""

# Check 1: ConfigMap exists
echo -n "1. ConfigMap 'app-config' exists: "
if kubectl get configmap app-config -n "$NAMESPACE" &>/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
fi

# Check 2: ConfigMap has correct APP_ENV
echo -n "2. ConfigMap APP_ENV=production: "
VAL=$(kubectl get configmap app-config -n "$NAMESPACE" -o jsonpath='{.data.APP_ENV}' 2>/dev/null || true)
if [[ "$VAL" == "production" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 3: ConfigMap has correct APP_DEBUG
echo -n "3. ConfigMap APP_DEBUG=false: "
VAL=$(kubectl get configmap app-config -n "$NAMESPACE" -o jsonpath='{.data.APP_DEBUG}' 2>/dev/null || true)
if [[ "$VAL" == "false" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 4: ConfigMap has correct APP_PORT
echo -n "4. ConfigMap APP_PORT=8080: "
VAL=$(kubectl get configmap app-config -n "$NAMESPACE" -o jsonpath='{.data.APP_PORT}' 2>/dev/null || true)
if [[ "$VAL" == "8080" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 5: Pod exists and is Running
echo -n "5. Pod 'config-pod' exists and is Running: "
PHASE=$(kubectl get pod config-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [[ "$PHASE" == "Running" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (phase: '$PHASE')"
  FAIL=$((FAIL + 1))
fi

# Check 6: Pod has envFrom referencing app-config
echo -n "6. Pod has envFrom referencing 'app-config': "
CM_REF=$(kubectl get pod config-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].envFrom[0].configMapRef.name}' 2>/dev/null || true)
if [[ "$CM_REF" == "app-config" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$CM_REF')"
  FAIL=$((FAIL + 1))
fi

# Check 7: Env vars are set in container
echo -n "7. Environment variables set in container: "
ENV_OUTPUT=$(kubectl exec config-pod -n "$NAMESPACE" -- env 2>/dev/null || true)
if echo "$ENV_OUTPUT" | grep -q "APP_ENV=production" && \
   echo "$ENV_OUTPUT" | grep -q "APP_DEBUG=false" && \
   echo "$ENV_OUTPUT" | grep -q "APP_PORT=8080"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
