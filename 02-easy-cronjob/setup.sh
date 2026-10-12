#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

NAMESPACE="ckad-cronjob"

echo "=== Setting up Exercise 02: CronJob Creation ==="

# Create namespace (idempotent)
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace '$NAMESPACE' is ready."
echo ""
echo "Your task: Create a CronJob named 'date-printer' with the specified schedule, image, and limits."
echo "Run verify.sh when you are done."
