#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0
TOTAL=8

NS="ckad-liveness"
POD="liveness-pod"

echo "=== Verifying Exercise 14: Liveness Probe ==="
echo ""

# Check 1: Pod exists and is Running
echo -n "Check 1: Pod '$POD' exists and is Running... "
POD_STATUS=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [ "$POD_STATUS" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: $POD_STATUS)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Container name is 'web'
echo -n "Check 2: Container name is 'web'... "
CONTAINER_NAME=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].name}' 2>/dev/null || echo "")
if [ "$CONTAINER_NAME" = "web" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$CONTAINER_NAME')"
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

# Check 4: Liveness probe exists and is httpGet
echo -n "Check 4: Liveness probe is httpGet... "
PROBE_TYPE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.httpGet}' 2>/dev/null || echo "")
if [ -n "$PROBE_TYPE" ] && [ "$PROBE_TYPE" != "" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (httpGet probe not found)"
  FAIL=$((FAIL + 1))
fi

# Check 5: Liveness probe path is /
echo -n "Check 5: Liveness probe path is '/'... "
PROBE_PATH=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null || echo "")
if [ "$PROBE_PATH" = "/" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$PROBE_PATH')"
  FAIL=$((FAIL + 1))
fi

# Check 6: Liveness probe port is 80
echo -n "Check 6: Liveness probe port is 80... "
PROBE_PORT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null || echo "")
if [ "$PROBE_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$PROBE_PORT')"
  FAIL=$((FAIL + 1))
fi

# Check 7: initialDelaySeconds is 5
echo -n "Check 7: initialDelaySeconds is 5... "
DELAY=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null || echo "")
if [ "$DELAY" = "5" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$DELAY')"
  FAIL=$((FAIL + 1))
fi

# Check 8: periodSeconds is 10
echo -n "Check 8: periodSeconds is 10... "
PERIOD=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null || echo "")
if [ "$PERIOD" = "10" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$PERIOD')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
