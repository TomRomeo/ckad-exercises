#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Setting up Exercise 18: Multi-Resource Troubleshooting ==="

# Create namespace (idempotent)
kubectl create namespace ckad-troubleshoot --dry-run=client -o yaml | kubectl apply -f -

# Deploy broken resources
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

# Give some time for pods to attempt starting
echo "Waiting a few seconds for pods to start (they will fail)..."
sleep 5

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-troubleshoot"
echo "Multiple resources have been deployed, but several things are broken."
echo "Resources created:"
echo "  - Deployment 'web-deploy' (pods are crashing)"
echo "  - Service 'web-svc' (not routing correctly)"
echo "  - ConfigMap 'app-conf' (contains DB configuration)"
echo ""
echo "Complete the tasks described in README.md"
