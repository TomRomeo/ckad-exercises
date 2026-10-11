#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 21: Resource Requests and Limits ==="
echo "Setting up namespace ckad-resources..."

kubectl create namespace ckad-resources --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Setup complete!"
echo ""
echo "Namespace: ckad-resources"
echo ""
echo "Tasks:"
echo "1. Create pod 'resource-pod' (nginx:1.25, container: web) with requests cpu=100m,mem=128Mi and limits cpu=250m,mem=256Mi"
echo "2. Create pod 'resource-pod-2' (busybox:1.36, container: worker, sleep 3600) with requests cpu=50m,mem=64Mi and limits cpu=100m,mem=128Mi"
