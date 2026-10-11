#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-canary"
PASS=0
FAIL=0
TOTAL=6

echo "=== Verifying Exercise 12: Canary Deployment ==="
echo ""

# Check 1: Deployment app-stable exists with 4 replicas and image nginx:1.24
echo -n "1. Deployment 'app-stable' exists (4 replicas, nginx:1.24): "
STABLE_EXISTS=$(kubectl get deployment app-stable -n "$NAMESPACE" >/dev/null 2>&1 && echo "yes" || echo "no")
if [ "$STABLE_EXISTS" = "yes" ]; then
    STABLE_REPLICAS=$(kubectl get deployment app-stable -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "")
    STABLE_IMAGE=$(kubectl get deployment app-stable -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")
    if [ "$STABLE_REPLICAS" = "4" ] && [ "$STABLE_IMAGE" = "nginx:1.24" ]; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL - replicas='$STABLE_REPLICAS' (expected 4), image='$STABLE_IMAGE' (expected nginx:1.24)"
        FAIL=$((FAIL + 1))
    fi
else
    echo "FAIL - Deployment 'app-stable' not found"
    FAIL=$((FAIL + 1))
fi

# Check 2: Deployment app-canary exists with 1 replica and image nginx:1.25
echo -n "2. Deployment 'app-canary' exists (1 replica, nginx:1.25): "
CANARY_EXISTS=$(kubectl get deployment app-canary -n "$NAMESPACE" >/dev/null 2>&1 && echo "yes" || echo "no")
if [ "$CANARY_EXISTS" = "yes" ]; then
    CANARY_REPLICAS=$(kubectl get deployment app-canary -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "")
    CANARY_IMAGE=$(kubectl get deployment app-canary -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")
    if [ "$CANARY_REPLICAS" = "1" ] && [ "$CANARY_IMAGE" = "nginx:1.25" ]; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL - replicas='$CANARY_REPLICAS' (expected 1), image='$CANARY_IMAGE' (expected nginx:1.25)"
        FAIL=$((FAIL + 1))
    fi
else
    echo "FAIL - Deployment 'app-canary' not found"
    FAIL=$((FAIL + 1))
fi

# Check 3: app-canary pods have labels app=my-app and version=canary
echo -n "3. Canary pods have labels app=my-app and version=canary: "
CANARY_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=my-app,version=canary --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$CANARY_PODS" -ge 1 ] 2>/dev/null; then
    echo "PASS ($CANARY_PODS canary pod(s) with correct labels)"
    PASS=$((PASS + 1))
else
    echo "FAIL - No pods found with labels app=my-app,version=canary"
    FAIL=$((FAIL + 1))
fi

# Check 4: Service my-app-svc selects app=my-app (not version)
echo -n "4. Service 'my-app-svc' selects on app=my-app (not version): "
SVC_SELECTOR=$(kubectl get service my-app-svc -n "$NAMESPACE" -o jsonpath='{.spec.selector}' 2>/dev/null || echo "")
if echo "$SVC_SELECTOR" | grep -q "my-app"; then
    # Ensure version is NOT in the selector
    VERSION_IN_SELECTOR=$(kubectl get service my-app-svc -n "$NAMESPACE" -o jsonpath='{.spec.selector.version}' 2>/dev/null || echo "")
    if [ -z "$VERSION_IN_SELECTOR" ]; then
        echo "PASS (selector: $SVC_SELECTOR)"
        PASS=$((PASS + 1))
    else
        echo "FAIL - Service selector includes 'version' key (should only select on app=my-app)"
        FAIL=$((FAIL + 1))
    fi
else
    echo "FAIL - Service selector doesn't include app=my-app (got: $SVC_SELECTOR)"
    FAIL=$((FAIL + 1))
fi

# Check 5: Total pods matching Service selector is 5 (4 stable + 1 canary)
echo -n "5. Total pods matching Service selector is 5: "
TOTAL_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=my-app --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL_PODS" = "5" ]; then
    echo "PASS (4 stable + 1 canary)"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 5 total pods with label app=my-app, got $TOTAL_PODS"
    FAIL=$((FAIL + 1))
fi

# Check 6: Service endpoints count is 5
echo -n "6. Service endpoints count is 5: "
ENDPOINTS=$(kubectl get endpoints my-app-svc -n "$NAMESPACE" -o jsonpath='{.subsets[0].addresses}' 2>/dev/null || echo "")
ENDPOINT_COUNT=$(echo "$ENDPOINTS" | grep -o '"ip"' | wc -l | tr -d ' ')
if [ "$ENDPOINT_COUNT" = "5" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 5 endpoints, got $ENDPOINT_COUNT"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
