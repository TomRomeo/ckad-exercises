#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 29: Create an Ingress Resource ==="
echo ""

# Create namespace (idempotent)
kubectl create namespace ckad-ingress --dry-run=client -o yaml | kubectl apply -f -

# Apply setup resources
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/web-app -n ckad-ingress --timeout=60s
kubectl rollout status deployment/api-app -n ckad-ingress --timeout=60s

echo ""
echo "Setup complete! Resources created:"
echo "  - Namespace: ckad-ingress"
echo "  - Deployment: web-app (2 replicas)"
echo "  - Deployment: api-app (2 replicas)"
echo "  - Service: web-svc (ClusterIP, port 80 -> web-app pods)"
echo "  - Service: api-svc (ClusterIP, port 80 -> api-app pods)"
echo ""
echo "Your task: Create an Ingress named 'app-ingress' with path-based routing."
echo "See README.md for full instructions."
