#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-rolling-update"

echo "=== Exercise 08: Rolling Update ==="
echo "Setting up namespace: $NAMESPACE"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying web-app with nginx:1.24..."
kubectl apply -f "$SCRIPT_DIR/setup-deployment.yaml"

echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/web-app -n "$NAMESPACE" --timeout=120s

echo ""
echo "Setup complete!"
echo "Deployment 'web-app' is running with image nginx:1.24 and 4 replicas."
echo ""
echo "Your task: Update the image to nginx:1.25, record the change cause,"
echo "and ensure the rollout completes successfully."
