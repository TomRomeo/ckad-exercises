#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

NAMESPACE="ckad-init-container"

echo "=== Setting up Exercise 04: Init Containers ==="

# Create namespace (idempotent)
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace '$NAMESPACE' is ready."
echo ""
echo "Your task: Create a pod with an init container that waits for a service, then create the service."
echo "Run verify.sh when you are done."
