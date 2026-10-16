#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

NAMESPACE="ckad-storageclass"
COURSE_DIR="/tmp/ckad-storageclass"

echo "=== Setting up Exercise 35: StorageClass and a Pending PVC ==="

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
mkdir -p "$COURSE_DIR"

echo ""
echo "Namespace '$NAMESPACE' is ready. Output directory: $COURSE_DIR"
echo "Your task: create StorageClass retain-sc, PVC data-pvc, and capture the pending reason."
echo "Run verify.sh when you are done."
