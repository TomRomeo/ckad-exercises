#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-bluegreen"

echo "=== Setting up Exercise 33: Blue-Green Deployment Cutover ==="

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

echo ""
echo "Namespace '$NAMESPACE' is ready with Deployments web-blue, web-green and Service web-svc."
echo "Your task: update web-green's image and switch web-svc to blue only (see README.md)."
echo "Run verify.sh when you are done."
