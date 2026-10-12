#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 27: Create a NodePort Service ==="
echo ""

# Create namespace (idempotent)
kubectl create namespace ckad-svc-nodeport --dry-run=client -o yaml | kubectl apply -f -

# Apply setup deployment
kubectl apply -f "$SCRIPT_DIR/setup-deployment.yaml"

# Wait for deployment to be ready
echo "Waiting for web-frontend deployment to be ready..."
kubectl rollout status deployment/web-frontend -n ckad-svc-nodeport --timeout=60s

echo ""
echo "Setup complete! Resources created:"
echo "  - Namespace: ckad-svc-nodeport"
echo "  - Deployment: web-frontend (2 replicas, image nginx:1.25)"
echo ""
echo "Your task: Create a NodePort Service named 'frontend-svc' on nodePort 30080."
echo "See README.md for full instructions."
