#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 19: ConfigMap Basics ==="
echo "Setting up namespace ckad-configmap..."

kubectl create namespace ckad-configmap --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Setup complete!"
echo ""
echo "Namespace: ckad-configmap"
echo ""
echo "Tasks:"
echo "1. Create a ConfigMap named 'app-config' with APP_ENV=production, APP_DEBUG=false, APP_PORT=8080"
echo "2. Create a pod named 'config-pod' (image: nginx:1.25) using envFrom with configMapRef"
echo "3. Container name should be 'app'"
