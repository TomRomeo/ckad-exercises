#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-rolling-update"
PASS=0
FAIL=0
TOTAL=5

echo "=== Verifying Exercise 08: Rolling Update ==="
echo ""

# Check 1: Deployment web-app exists
echo -n "1. Deployment 'web-app' exists: "
if kubectl get deployment web-app -n "$NAMESPACE" &>/dev/null; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Deployment 'web-app' not found in namespace '$NAMESPACE'"
    FAIL=$((FAIL + 1))
fi

# Check 2: Image is now nginx:1.25
echo -n "2. Image is nginx:1.25: "
IMAGE=$(kubectl get deployment web-app -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")
if [ "$IMAGE" = "nginx:1.25" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 'nginx:1.25', got '$IMAGE'"
    FAIL=$((FAIL + 1))
fi

# Check 3: All 4 pods running nginx:1.25
echo -n "3. All 4 pods running nginx:1.25: "
POD_IMAGES=$(kubectl get pods -n "$NAMESPACE" -l app=web-app -o jsonpath='{.items[*].spec.containers[0].image}' 2>/dev/null || echo "")
COUNT_125=$(echo "$POD_IMAGES" | tr ' ' '\n' | grep -c "nginx:1.25" || echo "0")
if [ "$COUNT_125" = "4" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 4 pods with nginx:1.25, got $COUNT_125"
    FAIL=$((FAIL + 1))
fi

# Check 4: Rollout status is complete
echo -n "4. Rollout is complete: "
UNAVAILABLE=$(kubectl get deployment web-app -n "$NAMESPACE" -o jsonpath='{.status.unavailableReplicas}' 2>/dev/null || echo "")
READY_REPLICAS=$(kubectl get deployment web-app -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [ -z "$UNAVAILABLE" ] && [ "$READY_REPLICAS" = "4" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Rollout not complete (unavailable: '$UNAVAILABLE', ready: '$READY_REPLICAS')"
    FAIL=$((FAIL + 1))
fi

# Check 5: Change cause annotation exists on the revision
echo -n "5. Change cause annotation exists: "
CHANGE_CAUSE=$(kubectl get deployment web-app -n "$NAMESPACE" -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || echo "")
if [ -n "$CHANGE_CAUSE" ]; then
    echo "PASS (cause: '$CHANGE_CAUSE')"
    PASS=$((PASS + 1))
else
    # Also check rollout history for change cause
    HISTORY_CAUSE=$(kubectl rollout history deployment/web-app -n "$NAMESPACE" 2>/dev/null | tail -1 | awk '{$1=""; print $0}' | xargs || echo "")
    if [ -n "$HISTORY_CAUSE" ] && [ "$HISTORY_CAUSE" != "<none>" ]; then
        echo "PASS (from history: '$HISTORY_CAUSE')"
        PASS=$((PASS + 1))
    else
        echo "FAIL - No change-cause annotation found"
        FAIL=$((FAIL + 1))
    fi
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
