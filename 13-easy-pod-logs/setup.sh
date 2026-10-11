#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Setting up Exercise 13: Pod Logs ==="

# Create namespace (idempotent)
kubectl create namespace ckad-logs --dry-run=client -o yaml | kubectl apply -f -

# Deploy the log-generator pod
kubectl apply -f "$SCRIPT_DIR/setup-pod.yaml"

# Wait for pod to be running
echo "Waiting for log-generator pod to be running..."
kubectl wait --for=condition=Ready pod/log-generator -n ckad-logs --timeout=60s

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-logs"
echo "Pod 'log-generator' is running and producing logs."
echo "Complete the tasks described in README.md"
