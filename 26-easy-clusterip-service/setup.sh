#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 26: Create a ClusterIP Service ==="
echo ""

# Create namespace (idempotent)
kubectl create namespace ckad-svc-clusterip --dry-run=client -o yaml | kubectl apply -f -

# Apply setup deployment
kubectl apply -f "$SCRIPT_DIR/setup-deployment.yaml"

# Wait for deployment to be ready
echo "Waiting for backend deployment to be ready..."
kubectl rollout status deployment/backend -n ckad-svc-clusterip --timeout=60s

echo ""
echo "Setup complete! Resources created:"
echo "  - Namespace: ckad-svc-clusterip"
echo "  - Deployment: backend (2 replicas, image nginx:1.25)"
echo ""
echo "Your task: Create a ClusterIP Service named 'backend-svc' that targets the backend pods."
echo "See README.md for full instructions."
