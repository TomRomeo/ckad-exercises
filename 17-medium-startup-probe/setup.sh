#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

echo "=== Setting up Exercise 17: Startup Probe ==="

# Create namespace (idempotent)
kubectl create namespace ckad-startup --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Setup complete ==="
echo "Namespace: ckad-startup"
echo "No resources pre-created. Complete the tasks described in README.md"
