#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 28: Create a Network Policy ==="
echo ""

# Create namespace (idempotent)
kubectl create namespace ckad-netpol --dry-run=client -o yaml | kubectl apply -f -

# Apply setup pods
kubectl apply -f "$SCRIPT_DIR/setup-pods.yaml"

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod/web -n ckad-netpol --timeout=60s
kubectl wait --for=condition=Ready pod/api -n ckad-netpol --timeout=60s
kubectl wait --for=condition=Ready pod/db -n ckad-netpol --timeout=60s

echo ""
echo "Setup complete! Resources created:"
echo "  - Namespace: ckad-netpol"
echo "  - Pod: web (labels: app=web, tier=frontend)"
echo "  - Pod: api (labels: app=api, tier=backend)"
echo "  - Pod: db  (labels: app=db, tier=database)"
echo ""
echo "Your task: Create a NetworkPolicy named 'db-policy' to restrict access to the db pod."
echo "See README.md for full instructions."
