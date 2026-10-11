#!/bin/bash
set -euo pipefail

NS="ckad-svc-nodeport"
PASS=0
FAIL=0
TOTAL=7

echo "=== Verifying Exercise 27: NodePort Service ==="
echo ""

# Check 1: Service exists
echo -n "Check 1/7 - Service 'frontend-svc' exists: "
if kubectl get service frontend-svc -n "$NS" 2>/dev/null >&2; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Service 'frontend-svc' not found in namespace '$NS'"
  FAIL=$((FAIL + 1))
fi

# Check 2: Service type is NodePort
echo -n "Check 2/7 - Service type is NodePort: "
SVC_TYPE=$(kubectl get service frontend-svc -n "$NS" -o jsonpath='{.spec.type}' 2>/dev/null || echo "")
if [ "$SVC_TYPE" = "NodePort" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected 'NodePort', got '$SVC_TYPE'"
  FAIL=$((FAIL + 1))
fi

# Check 3: Service port is 80
echo -n "Check 3/7 - Service port is 80: "
SVC_PORT=$(kubectl get service frontend-svc -n "$NS" -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || echo "")
if [ "$SVC_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected port 80, got '$SVC_PORT'"
  FAIL=$((FAIL + 1))
fi

# Check 4: Target port is 80
echo -n "Check 4/7 - Target port is 80: "
SVC_TARGET_PORT=$(kubectl get service frontend-svc -n "$NS" -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null || echo "")
if [ "$SVC_TARGET_PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected targetPort 80, got '$SVC_TARGET_PORT'"
  FAIL=$((FAIL + 1))
fi

# Check 5: Node port is 30080
echo -n "Check 5/7 - NodePort is 30080: "
NODE_PORT=$(kubectl get service frontend-svc -n "$NS" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "")
if [ "$NODE_PORT" = "30080" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected nodePort 30080, got '$NODE_PORT'"
  FAIL=$((FAIL + 1))
fi

# Check 6: Selector is app=web-frontend
echo -n "Check 6/7 - Selector is app=web-frontend: "
SELECTOR=$(kubectl get service frontend-svc -n "$NS" -o jsonpath='{.spec.selector.app}' 2>/dev/null || echo "")
if [ "$SELECTOR" = "web-frontend" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected selector app=web-frontend, got app='$SELECTOR'"
  FAIL=$((FAIL + 1))
fi

# Check 7: Service has endpoints
echo -n "Check 7/7 - Service has endpoints: "
ENDPOINT_COUNT=$(kubectl get endpoints frontend-svc -n "$NS" -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o '"ip"' | wc -l | tr -d ' ')
if [ "$ENDPOINT_COUNT" -ge 1 ] 2>/dev/null; then
  echo "PASS ($ENDPOINT_COUNT endpoints)"
  PASS=$((PASS + 1))
else
  echo "FAIL - No endpoints found"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
