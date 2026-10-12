#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-labels"

echo "=== Setting up Exercise 32: Bulk Labels and Annotations by Selector ==="

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

echo ""
echo "Namespace '$NAMESPACE' is ready with pods labelled type=worker/runner/other."
echo "Your task: label + annotate the worker/runner pods as described in README.md."
echo "Run verify.sh when you are done."
