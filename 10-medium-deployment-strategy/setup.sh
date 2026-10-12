#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-deploy-strategy"

echo "=== Exercise 10: Deployment Strategy Configuration ==="
echo "Setting up namespace: $NAMESPACE"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Setup complete!"
echo "Namespace '$NAMESPACE' is ready."
echo ""
echo "Your task: Create a Deployment named 'strategy-app' with image nginx:1.25,"
echo "5 replicas, RollingUpdate strategy (maxSurge: 2, maxUnavailable: 1),"
echo "minReadySeconds: 10, and revisionHistoryLimit: 5."
