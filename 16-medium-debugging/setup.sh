#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Setting up Exercise 16: Debugging a Broken Pod ==="

# Create namespace (idempotent)
kubectl create namespace ckad-debug --dry-run=client -o yaml | kubectl apply -f -

# Deploy the broken pod
kubectl apply -f "$SCRIPT_DIR/setup-broken-pod.yaml"

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-debug"
echo "Pod 'broken-pod' has been deployed but something is wrong..."
echo "Complete the tasks described in README.md"
