#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-init-container"
PASS=0
FAIL=0
TOTAL=6

echo "=== Verifying Exercise 04: Init Containers ==="
echo ""

# Check 1: Pod 'init-pod' exists
echo -n "Check 1/6 - Pod 'init-pod' exists: "
if kubectl get pod init-pod -n "$NAMESPACE" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (pod not found)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Pod has init container named 'init-svc-check'
echo -n "Check 2/6 - Init container 'init-svc-check' exists: "
INIT_NAME=$(kubectl get pod init-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="init-svc-check")].name}' 2>/dev/null) || INIT_NAME=""
if [ "$INIT_NAME" = "init-svc-check" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (init container name: '${INIT_NAME:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Init container uses busybox:1.36
echo -n "Check 3/6 - Init container uses busybox:1.36: "
INIT_IMAGE=$(kubectl get pod init-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="init-svc-check")].image}' 2>/dev/null) || INIT_IMAGE=""
if [ "$INIT_IMAGE" = "busybox:1.36" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (image: '${INIT_IMAGE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: Main container 'main-app' uses nginx:1.25
echo -n "Check 4/6 - Main container 'main-app' uses nginx:1.25: "
MAIN_IMAGE=$(kubectl get pod init-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="main-app")].image}' 2>/dev/null) || MAIN_IMAGE=""
if [ "$MAIN_IMAGE" = "nginx:1.25" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (image: '${MAIN_IMAGE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: Service 'init-svc' exists
echo -n "Check 5/6 - Service 'init-svc' exists: "
if kubectl get svc init-svc -n "$NAMESPACE" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (service not found)"
  FAIL=$((FAIL + 1))
fi

# Check 6: Pod is eventually Running (wait up to 30s)
echo -n "Check 6/6 - Pod is Running (waiting up to 30s): "
POD_RUNNING=false
for i in $(seq 1 15); do
  POD_STATUS=$(kubectl get pod init-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null) || POD_STATUS=""
  if [ "$POD_STATUS" = "Running" ]; then
    POD_RUNNING=true
    break
  fi
  sleep 2
done
if [ "$POD_RUNNING" = true ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  POD_STATUS=$(kubectl get pod init-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null) || POD_STATUS="not found"
  echo "FAIL (status: '$POD_STATUS' after 30s)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
