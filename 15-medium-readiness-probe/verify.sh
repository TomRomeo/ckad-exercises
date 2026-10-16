#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0
TOTAL=7

NS="ckad-readiness"
DEPLOY="ready-app"

echo "=== Verifying Exercise 15: Readiness Probe ==="
echo ""

# Check 1: Deployment exists
echo -n "Check 1: Deployment '$DEPLOY' exists... "
if kubectl get deployment "$DEPLOY" -n "$NS" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (deployment not found)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Readiness probe is httpGet on path / port 80
echo -n "Check 2: Readiness probe is httpGet on path '/' port 80... "
PROBE_PATH=$(kubectl get deployment "$DEPLOY" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null || echo "")
PROBE_PORT=$(kubectl get deployment "$DEPLOY" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null || echo "")
if [ "$PROBE_PATH" = "/" ] && [ "$PROBE_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (path='$PROBE_PATH', port='$PROBE_PORT')"
  FAIL=$((FAIL + 1))
fi

# Check 3: initialDelaySeconds is 3
echo -n "Check 3: initialDelaySeconds is 3... "
DELAY=$(kubectl get deployment "$DEPLOY" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null || echo "")
if [ "$DELAY" = "3" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$DELAY')"
  FAIL=$((FAIL + 1))
fi

# Check 4: periodSeconds is 5
echo -n "Check 4: periodSeconds is 5... "
PERIOD=$(kubectl get deployment "$DEPLOY" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null || echo "")
if [ "$PERIOD" = "5" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$PERIOD')"
  FAIL=$((FAIL + 1))
fi

# Check 5: failureThreshold is 3
echo -n "Check 5: failureThreshold is 3... "
THRESHOLD=$(kubectl get deployment "$DEPLOY" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.failureThreshold}' 2>/dev/null || echo "")
if [ "$THRESHOLD" = "3" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$THRESHOLD')"
  FAIL=$((FAIL + 1))
fi

# Check 6: All 3 pods are Ready
echo -n "Check 6: All 3 pods are Ready... "
READY_COUNT=$(kubectl get pods -n "$NS" -l app=ready-app -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' 2>/dev/null | grep -c "True" || true)
if [ "$READY_COUNT" = "3" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL ($READY_COUNT of 3 pods ready)"
  FAIL=$((FAIL + 1))
fi

# Check 7: Service has 3 endpoints
echo -n "Check 7: Service 'ready-svc' has 3 endpoints... "
ENDPOINT_COUNT=$(kubectl get endpoints ready-svc -n "$NS" -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
if [ "$ENDPOINT_COUNT" = "3" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL ($ENDPOINT_COUNT endpoints, expected 3)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
