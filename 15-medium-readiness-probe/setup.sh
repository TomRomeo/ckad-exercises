#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Setting up Exercise 15: Readiness Probe ==="

# Create namespace (idempotent)
kubectl create namespace ckad-readiness --dry-run=client -o yaml | kubectl apply -f -

# Deploy resources
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

# Wait for deployment to be available
echo "Waiting for Deployment 'ready-app' to be available..."
kubectl wait --for=condition=Available deployment/ready-app -n ckad-readiness --timeout=120s

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-readiness"
echo "Deployment 'ready-app' is running with 3 replicas (no readiness probe)."
echo "Service 'ready-svc' is targeting app=ready-app."
echo "Complete the tasks described in README.md"
