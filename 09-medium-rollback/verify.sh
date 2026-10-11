#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-rollback"
PASS=0
FAIL=0
TOTAL=4

echo "=== Verifying Exercise 09: Rollback a Deployment ==="
echo ""

# Check 1: Deployment rollback-app exists
echo -n "1. Deployment 'rollback-app' exists: "
if kubectl get deployment rollback-app -n "$NAMESPACE" &>/dev/null; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Deployment 'rollback-app' not found in namespace '$NAMESPACE'"
    FAIL=$((FAIL + 1))
fi

# Check 2: Current image is nginx:1.24
echo -n "2. Current image is nginx:1.24: "
IMAGE=$(kubectl get deployment rollback-app -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")
if [ "$IMAGE" = "nginx:1.24" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 'nginx:1.24', got '$IMAGE'"
    FAIL=$((FAIL + 1))
fi

# Check 3: All 3 pods are Running and Ready
echo -n "3. All 3 pods are Running and Ready: "
READY_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=rollback-app -o jsonpath='{range .items[*]}{.status.phase}{" "}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep "Running true" | wc -l | tr -d ' ')
if [ "$READY_PODS" = "3" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 3 running and ready pods, got $READY_PODS"
    FAIL=$((FAIL + 1))
fi

# Check 4: Rollout is complete (no unavailable replicas)
echo -n "4. Rollout is complete (no unavailable replicas): "
UNAVAILABLE=$(kubectl get deployment rollback-app -n "$NAMESPACE" -o jsonpath='{.status.unavailableReplicas}' 2>/dev/null || echo "")
READY_REPLICAS=$(kubectl get deployment rollback-app -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
DESIRED=$(kubectl get deployment rollback-app -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
if [ -z "$UNAVAILABLE" ] && [ "$READY_REPLICAS" = "$DESIRED" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Rollout not complete (unavailable: '${UNAVAILABLE:-0}', ready: '$READY_REPLICAS', desired: '$DESIRED')"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
