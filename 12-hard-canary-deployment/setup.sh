#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-canary"

echo "=== Exercise 12: Canary Deployment ==="
echo "Setting up namespace: $NAMESPACE"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying stable app and service..."
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

echo "Waiting for stable deployment to be ready..."
kubectl rollout status deployment/app-stable -n "$NAMESPACE" --timeout=120s

echo ""
echo "Setup complete!"
echo "Deployment 'app-stable' is running with 4 replicas (nginx:1.24)."
echo "Service 'my-app-svc' selects on app=my-app."
echo ""
echo "Your task: Create a canary Deployment 'app-canary' with 1 replica of nginx:1.25"
echo "using labels app=my-app and version=canary so the Service routes to both."
