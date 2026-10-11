#!/bin/bash
set -euo pipefail

echo "=== Setting up Exercise 17: Startup Probe ==="

# Create namespace (idempotent)
kubectl create namespace ckad-startup --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-startup"
echo "No resources pre-created. Complete the tasks described in README.md"
