#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0
TOTAL=4

NS="ckad-debug"
POD="broken-pod"

echo "=== Verifying Exercise 16: Debugging a Broken Pod ==="
echo ""

# Check 1: Pod broken-pod exists
echo -n "Check 1: Pod '$POD' exists... "
if kubectl get pod "$POD" -n "$NS" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (pod not found)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Pod is Running
echo -n "Check 2: Pod '$POD' is Running... "
POD_STATUS=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [ "$POD_STATUS" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: $POD_STATUS)"
  FAIL=$((FAIL + 1))
fi

# Check 3: Image is nginx:1.25
echo -n "Check 3: Image is 'nginx:1.25'... "
IMAGE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].image}' 2>/dev/null || echo "")
if [ "$IMAGE" = "nginx:1.25" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$IMAGE')"
  FAIL=$((FAIL + 1))
fi

# Check 4: No pods in ImagePullBackOff/ErrImagePull state
echo -n "Check 4: No pods in ImagePullBackOff/ErrImagePull state... "
BAD_PODS=$(kubectl get pods -n "$NS" -o jsonpath='{range .items[*]}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}' 2>/dev/null | grep -cE "(ImagePullBackOff|ErrImagePull)" || true)
if [ "$BAD_PODS" = "0" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL ($BAD_PODS pod(s) with image pull errors)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
