#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0
TOTAL=9

NS="ckad-startup"
POD="slow-start-pod"

echo "=== Verifying Exercise 17: Startup Probe ==="
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

# Check 2: Container name is 'app'
echo -n "Check 2: Container name is 'app'... "
CONTAINER_NAME=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].name}' 2>/dev/null || echo "")
if [ "$CONTAINER_NAME" = "app" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$CONTAINER_NAME')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Startup probe - httpGet on / port 80
echo -n "Check 3: Startup probe is httpGet on '/' port 80... "
SP_PATH=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].startupProbe.httpGet.path}' 2>/dev/null || echo "")
SP_PORT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].startupProbe.httpGet.port}' 2>/dev/null || echo "")
if [ "$SP_PATH" = "/" ] && [ "$SP_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (path='$SP_PATH', port='$SP_PORT')"
  FAIL=$((FAIL + 1))
fi

# Check 4: Startup probe failureThreshold is 30
echo -n "Check 4: Startup probe failureThreshold is 30... "
SP_FT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].startupProbe.failureThreshold}' 2>/dev/null || echo "")
if [ "$SP_FT" = "30" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$SP_FT')"
  FAIL=$((FAIL + 1))
fi

# Check 5: Startup probe periodSeconds is 2
echo -n "Check 5: Startup probe periodSeconds is 2... "
SP_PS=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].startupProbe.periodSeconds}' 2>/dev/null || echo "")
if [ "$SP_PS" = "2" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$SP_PS')"
  FAIL=$((FAIL + 1))
fi

# Check 6: Liveness probe - httpGet on / port 80
echo -n "Check 6: Liveness probe is httpGet on '/' port 80... "
LP_PATH=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null || echo "")
LP_PORT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null || echo "")
if [ "$LP_PATH" = "/" ] && [ "$LP_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (path='$LP_PATH', port='$LP_PORT')"
  FAIL=$((FAIL + 1))
fi

# Check 7: Liveness probe periodSeconds is 10
echo -n "Check 7: Liveness probe periodSeconds is 10... "
LP_PS=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null || echo "")
if [ "$LP_PS" = "10" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$LP_PS')"
  FAIL=$((FAIL + 1))
fi

# Check 8: Readiness probe - httpGet on / port 80
echo -n "Check 8: Readiness probe is httpGet on '/' port 80... "
RP_PATH=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null || echo "")
RP_PORT=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null || echo "")
if [ "$RP_PATH" = "/" ] && [ "$RP_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (path='$RP_PATH', port='$RP_PORT')"
  FAIL=$((FAIL + 1))
fi

# Check 9: Readiness probe periodSeconds is 5
echo -n "Check 9: Readiness probe periodSeconds is 5... "
RP_PS=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null || echo "")
if [ "$RP_PS" = "5" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$RP_PS')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
