#!/bin/bash
set -euo pipefail

echo "=== Setting up Exercise 14: Liveness Probe ==="

# Create namespace (idempotent)
kubectl create namespace ckad-liveness --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-liveness"
echo "No resources pre-created. Complete the tasks described in README.md"
