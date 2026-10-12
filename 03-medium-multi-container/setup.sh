#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

NAMESPACE="ckad-multi-container"

echo "=== Setting up Exercise 03: Multi-Container Pod (Sidecar Pattern) ==="

# Create namespace (idempotent)
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace '$NAMESPACE' is ready."
echo ""
echo "Your task: Create a pod named 'sidecar-pod' with two containers sharing a log volume."
echo "Run verify.sh when you are done."
