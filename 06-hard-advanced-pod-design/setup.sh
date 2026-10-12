#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

NAMESPACE="ckad-adv-pod"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Setting up Exercise 06: Advanced Pod Design ==="

# Create namespace (idempotent)
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Apply ConfigMap and Secret
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

echo "Namespace '$NAMESPACE' is ready."
echo "ConfigMap 'app-config' and Secret 'app-secret' have been created."
echo ""
echo "Your task: Create an advanced pod with init containers, sidecars, volumes, and resource limits."
echo "Run verify.sh when you are done."
