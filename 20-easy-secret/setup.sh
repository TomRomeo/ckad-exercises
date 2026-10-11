#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 20: Secret Basics ==="
echo "Setting up namespace ckad-secret..."

kubectl create namespace ckad-secret --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Setup complete!"
echo ""
echo "Namespace: ckad-secret"
echo ""
echo "Tasks:"
echo "1. Create a Secret named 'db-credentials' (type Opaque) with username=admin, password=S3cur3P@ss!"
echo "2. Create a pod named 'secret-pod' (image: nginx:1.25, container: app)"
echo "3. Mount the secret as a volume at /etc/secrets (volume name: secret-vol)"
