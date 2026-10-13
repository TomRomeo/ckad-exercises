#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-pullpolicy"

echo "=== Setting up Exercise 38: Image Pull Policy and Graceful Termination ==="

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

echo ""
echo "Namespace '$NAMESPACE' is ready with Deployment harvester (containers app + sidecar)."
echo "Your task: set imagePullPolicy per container and terminationGracePeriodSeconds (see README.md)."
echo "Run verify.sh when you are done."
