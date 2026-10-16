#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-deploy-basics"
PASS=0
FAIL=0
TOTAL=6

echo "=== Verifying Exercise 07: Deployment Basics ==="
echo ""

# Check 1: Deployment webapp exists
echo -n "1. Deployment 'webapp' exists: "
if kubectl get deployment webapp -n "$NAMESPACE" &>/dev/null; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Deployment 'webapp' not found in namespace '$NAMESPACE'"
    FAIL=$((FAIL + 1))
fi

# Check 2: Replicas set to 3
echo -n "2. Replicas set to 3: "
REPLICAS=$(kubectl get deployment webapp -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "")
if [ "$REPLICAS" = "3" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 3 replicas, got '$REPLICAS'"
    FAIL=$((FAIL + 1))
fi

# Check 3: Image is nginx:1.25
echo -n "3. Image is nginx:1.25: "
IMAGE=$(kubectl get deployment webapp -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")
if [ "$IMAGE" = "nginx:1.25" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 'nginx:1.25', got '$IMAGE'"
    FAIL=$((FAIL + 1))
fi

# Check 4: 3 pods are Ready
echo -n "4. 3 pods are Ready: "
READY_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=webapp --field-selector=status.phase=Running -o jsonpath='{.items[*].status.containerStatuses[0].ready}' 2>/dev/null | tr ' ' '\n' | grep -c "true" || true)
if [ "$READY_PODS" = "3" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected 3 ready pods, got $READY_PODS"
    FAIL=$((FAIL + 1))
fi

# Check 5: Label app=webapp on pods
echo -n "5. Label 'app=webapp' on pods: "
LABELED_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=webapp --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$LABELED_PODS" -ge 3 ] 2>/dev/null; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected at least 3 pods with label app=webapp, got $LABELED_PODS"
    FAIL=$((FAIL + 1))
fi

# Check 6: Container name is nginx
echo -n "6. Container name is 'nginx': "
CONTAINER_NAME=$(kubectl get deployment webapp -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null || echo "")
if [ "$CONTAINER_NAME" = "nginx" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Expected container name 'nginx', got '$CONTAINER_NAME'"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
