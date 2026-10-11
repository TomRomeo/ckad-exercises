#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-helm"
PASS=0
FAIL=0
TOTAL=5

echo "=== Verifying Exercise 11: Helm Basics ==="
echo ""

# Pre-check: helm is installed
if ! command -v helm &>/dev/null; then
    echo "SKIP - helm is not installed. Cannot verify this exercise."
    echo "Results: 0 passed, 0 failed out of $TOTAL (SKIPPED)"
    exit 0
fi

# Check 1: Helm repo bitnami exists
echo -n "1. Helm repo 'bitnami' exists: "
if helm repo list 2>/dev/null | grep -q "bitnami"; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Helm repo 'bitnami' not found (run: helm repo add bitnami https://charts.bitnami.com/bitnami)"
    FAIL=$((FAIL + 1))
fi

# Check 2: Release my-nginx exists in namespace ckad-helm
echo -n "2. Release 'my-nginx' exists in namespace '$NAMESPACE': "
if helm list -n "$NAMESPACE" 2>/dev/null | grep -q "my-nginx"; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL - Release 'my-nginx' not found in namespace '$NAMESPACE'"
    FAIL=$((FAIL + 1))
fi

# Check 3: Release status is deployed
echo -n "3. Release status is 'deployed': "
STATUS=$(helm status my-nginx -n "$NAMESPACE" -o json 2>/dev/null | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
if [ "$STATUS" = "deployed" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    # Fallback: check from helm list
    STATUS=$(helm list -n "$NAMESPACE" --filter 'my-nginx' -o json 2>/dev/null | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")
    if [ "$STATUS" = "deployed" ]; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL - Expected status 'deployed', got '$STATUS'"
        FAIL=$((FAIL + 1))
    fi
fi

# Check 4: At least 1 pod is running in the namespace
echo -n "4. At least 1 pod running in namespace '$NAMESPACE': "
RUNNING_PODS=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$RUNNING_PODS" -ge 1 ] 2>/dev/null; then
    echo "PASS ($RUNNING_PODS pods running)"
    PASS=$((PASS + 1))
else
    echo "FAIL - No running pods found in namespace '$NAMESPACE'"
    FAIL=$((FAIL + 1))
fi

# Check 5: Replica count is 2 (check deployment)
echo -n "5. Replica count is 2: "
# Find the deployment created by the helm release
DEPLOY_NAME=$(kubectl get deployments -n "$NAMESPACE" --no-headers 2>/dev/null | awk '{print $1}' | head -1 || echo "")
if [ -n "$DEPLOY_NAME" ]; then
    REPLICAS=$(kubectl get deployment "$DEPLOY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "")
    if [ "$REPLICAS" = "2" ]; then
        echo "PASS (deployment: $DEPLOY_NAME)"
        PASS=$((PASS + 1))
    else
        echo "FAIL - Expected 2 replicas on deployment '$DEPLOY_NAME', got '$REPLICAS'"
        FAIL=$((FAIL + 1))
    fi
else
    echo "FAIL - No deployment found in namespace '$NAMESPACE'"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
