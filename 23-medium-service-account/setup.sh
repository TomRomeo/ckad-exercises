#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 23: ServiceAccount Configuration ==="
echo "Setting up namespace ckad-sa..."

kubectl create namespace ckad-sa --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Setup complete!"
echo ""
echo "Namespace: ckad-sa"
echo ""
echo "Tasks:"
echo "1. Create a ServiceAccount named 'app-sa'"
echo "2. Create a pod named 'sa-pod' (image: nginx:1.25, container: app)"
echo "3. Configure the pod to use ServiceAccount 'app-sa'"
echo "4. Set automountServiceAccountToken: false on the pod spec"
