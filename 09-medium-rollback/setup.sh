#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-rollback"

echo "=== Exercise 09: Rollback a Deployment ==="
echo "Setting up namespace: $NAMESPACE"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying rollback-app with nginx:1.23 (revision 1)..."
kubectl apply -f "$SCRIPT_DIR/setup-deployment.yaml"
kubectl rollout status deployment/rollback-app -n "$NAMESPACE" --timeout=120s

echo "Updating to nginx:1.24 (revision 2)..."
kubectl set image deployment/rollback-app nginx=nginx:1.24 -n "$NAMESPACE"
kubectl annotate deployment/rollback-app kubernetes.io/change-cause="Updated to nginx:1.24" -n "$NAMESPACE" --overwrite
kubectl rollout status deployment/rollback-app -n "$NAMESPACE" --timeout=120s

echo "Updating to nginx:1.25-nonexistent (revision 3 - BROKEN)..."
kubectl set image deployment/rollback-app nginx=nginx:1.25-nonexistent -n "$NAMESPACE"
kubectl annotate deployment/rollback-app kubernetes.io/change-cause="Updated to nginx:1.25-nonexistent (broken)" -n "$NAMESPACE" --overwrite

# Wait a bit for the broken rollout to start failing
sleep 5

echo ""
echo "Setup complete!"
echo "Deployment 'rollback-app' is now BROKEN (using non-existent image tag)."
echo ""
echo "Your task: Check the rollout history, identify the working revision,"
echo "and roll back to nginx:1.24."
