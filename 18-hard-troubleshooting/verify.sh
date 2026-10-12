#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0
TOTAL=6

NS="ckad-troubleshoot"

echo "=== Verifying Exercise 18: Multi-Resource Troubleshooting ==="
echo ""

# Check 1: Deployment web-deploy pods are Running (not CrashLoopBackOff)
echo -n "Check 1: Deployment 'web-deploy' pods are Running... "
RUNNING_PODS=$(kubectl get pods -n "$NS" -l app=web -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' 2>/dev/null | grep -c "Running" || true)
TOTAL_DEPLOY_PODS=$(kubectl get deployment web-deploy -n "$NS" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
if [ "$RUNNING_PODS" -ge 1 ] && [ "$RUNNING_PODS" = "$TOTAL_DEPLOY_PODS" ]; then
  echo "PASS ($RUNNING_PODS/$TOTAL_DEPLOY_PODS running)"
  PASS=$((PASS + 1))
else
  echo "FAIL ($RUNNING_PODS/$TOTAL_DEPLOY_PODS running)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Service web-svc selector is app=web
echo -n "Check 2: Service 'web-svc' selector is 'app: web'... "
SVC_SELECTOR=$(kubectl get svc web-svc -n "$NS" -o jsonpath='{.spec.selector.app}' 2>/dev/null || echo "")
if [ "$SVC_SELECTOR" = "web" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (selector app='$SVC_SELECTOR')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Service has endpoints (at least 1)
echo -n "Check 3: Service 'web-svc' has endpoints... "
ENDPOINTS=$(kubectl get endpoints web-svc -n "$NS" -o jsonpath='{.subsets[0].addresses}' 2>/dev/null || echo "")
if [ -n "$ENDPOINTS" ] && [ "$ENDPOINTS" != "" ] && [ "$ENDPOINTS" != "null" ]; then
  ENDPOINT_COUNT=$(echo "$ENDPOINTS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
  if [ "$ENDPOINT_COUNT" -ge 1 ]; then
    echo "PASS ($ENDPOINT_COUNT endpoints)"
    PASS=$((PASS + 1))
  else
    echo "FAIL (0 endpoints)"
    FAIL=$((FAIL + 1))
  fi
else
  echo "FAIL (no endpoints found)"
  FAIL=$((FAIL + 1))
fi

# Check 4: Pod debug-pod exists and is Running
echo -n "Check 4: Pod 'debug-pod' exists and is Running... "
DEBUG_STATUS=$(kubectl get pod debug-pod -n "$NS" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NOT_FOUND")
if [ "$DEBUG_STATUS" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: $DEBUG_STATUS)"
  FAIL=$((FAIL + 1))
fi

# Check 5: debug-pod has env var DB_HOST=mysql-svc
echo -n "Check 5: debug-pod has env var DB_HOST=mysql-svc... "
DB_HOST=$(kubectl exec debug-pod -n "$NS" -- env 2>/dev/null | grep "^DB_HOST=" | cut -d= -f2 || echo "")
if [ "$DB_HOST" = "mysql-svc" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (DB_HOST='$DB_HOST')"
  FAIL=$((FAIL + 1))
fi

# Check 6: debug-pod has env var DB_PORT=3306
echo -n "Check 6: debug-pod has env var DB_PORT=3306... "
DB_PORT=$(kubectl exec debug-pod -n "$NS" -- env 2>/dev/null | grep "^DB_PORT=" | cut -d= -f2 || echo "")
if [ "$DB_PORT" = "3306" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (DB_PORT='$DB_PORT')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
