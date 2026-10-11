#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 24: ResourceQuota and LimitRange ==="
echo "Setting up namespace ckad-quota..."

kubectl create namespace ckad-quota --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Setup complete!"
echo ""
echo "Namespace: ckad-quota"
echo ""
echo "Tasks:"
echo "1. Create ResourceQuota 'compute-quota' with requests.cpu=1, requests.memory=1Gi, limits.cpu=2, limits.memory=2Gi, pods=5"
echo "2. Create LimitRange 'default-limits' with default limits cpu=200m,mem=256Mi and default requests cpu=100m,mem=128Mi"
echo "3. Create pod 'quota-pod' (nginx:1.25, container: app) with explicit requests cpu=150m,mem=200Mi and limits cpu=300m,mem=400Mi"
