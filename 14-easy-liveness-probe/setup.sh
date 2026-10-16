#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

echo "=== Setting up Exercise 14: Liveness Probe ==="

# Create namespace (idempotent)
kubectl create namespace ckad-liveness --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-liveness"
echo "No resources pre-created. Complete the tasks described in README.md"
