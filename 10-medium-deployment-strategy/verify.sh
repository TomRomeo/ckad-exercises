#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-deploy-strategy"
PASS=0
FAIL=0
TOTAL=7

echo "=== Verifying Exercise 10: Deployment Strategy Configuration ==="
echo ""

# Check 1: Deployment exists
echo -n "1. Deployment 'strategy-app' exists: "
if kubectl get deployment strategy-app -n "$NAMESPACE" &>/dev/null; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Deployment 'strategy-app' not found in namespace '$NAMESPACE'"
    FAIL=$((FAIL + 1))
fi

# Check 2: Strategy is RollingUpdate
echo -n "2. Strategy is RollingUpdate: "
STRATEGY=$(kubectl get deployment strategy-app -n "$NAMESPACE" -o jsonpath='{.spec.strategy.type}' 2>/dev/null || echo "")
if [ "$STRATEGY" = "RollingUpdate" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 'RollingUpdate', got '$STRATEGY'"
    FAIL=$((FAIL + 1))
fi

# Check 3: maxSurge is 2
echo -n "3. maxSurge is 2: "
MAX_SURGE=$(kubectl get deployment strategy-app -n "$NAMESPACE" -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null || echo "")
if [ "$MAX_SURGE" = "2" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected maxSurge '2', got '$MAX_SURGE'"
    FAIL=$((FAIL + 1))
fi

# Check 4: maxUnavailable is 1
echo -n "4. maxUnavailable is 1: "
MAX_UNAVAIL=$(kubectl get deployment strategy-app -n "$NAMESPACE" -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null || echo "")
if [ "$MAX_UNAVAIL" = "1" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected maxUnavailable '1', got '$MAX_UNAVAIL'"
    FAIL=$((FAIL + 1))
fi

# Check 5: minReadySeconds is 10
echo -n "5. minReadySeconds is 10: "
MIN_READY=$(kubectl get deployment strategy-app -n "$NAMESPACE" -o jsonpath='{.spec.minReadySeconds}' 2>/dev/null || echo "")
if [ "$MIN_READY" = "10" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected minReadySeconds '10', got '$MIN_READY'"
    FAIL=$((FAIL + 1))
fi

# Check 6: revisionHistoryLimit is 5
echo -n "6. revisionHistoryLimit is 5: "
REV_LIMIT=$(kubectl get deployment strategy-app -n "$NAMESPACE" -o jsonpath='{.spec.revisionHistoryLimit}' 2>/dev/null || echo "")
if [ "$REV_LIMIT" = "5" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected revisionHistoryLimit '5', got '$REV_LIMIT'"
    FAIL=$((FAIL + 1))
fi

# Check 7: 5 replicas running
echo -n "7. 5 replicas running: "
READY_REPLICAS=$(kubectl get deployment strategy-app -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [ "$READY_REPLICAS" = "5" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 5 ready replicas, got '$READY_REPLICAS'"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
