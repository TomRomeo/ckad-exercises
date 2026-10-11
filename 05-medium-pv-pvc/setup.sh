#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-volumes"

echo "=== Setting up Exercise 05: PersistentVolume and PersistentVolumeClaim ==="

# Create namespace (idempotent)
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace '$NAMESPACE' is ready."
echo ""
echo "Your task: Create a PV, PVC, and a pod that uses the PVC."
echo "Run verify.sh when you are done."
