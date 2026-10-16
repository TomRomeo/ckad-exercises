#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 30: Advanced Network Policies ==="
echo ""

# Create namespaces (idempotent)
kubectl create namespace ckad-netpol-adv --dry-run=client -o yaml | kubectl apply -f -

kubectl create namespace ckad-netpol-external --dry-run=client -o yaml | kubectl apply -f -

# Apply setup resources
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod/frontend -n ckad-netpol-adv --timeout=60s
kubectl wait --for=condition=Ready pod/backend -n ckad-netpol-adv --timeout=60s
kubectl wait --for=condition=Ready pod/database -n ckad-netpol-adv --timeout=60s
kubectl wait --for=condition=Ready pod/monitoring -n ckad-netpol-external --timeout=60s

echo ""
echo "Setup complete! Resources created:"
echo "  - Namespace: ckad-netpol-adv"
echo "  - Namespace: ckad-netpol-external"
echo "  - Pod: frontend  (ns: ckad-netpol-adv, labels: app=frontend, tier=web)"
echo "  - Pod: backend   (ns: ckad-netpol-adv, labels: app=backend, tier=api)"
echo "  - Pod: database  (ns: ckad-netpol-adv, labels: app=database, tier=data)"
echo "  - Pod: monitoring (ns: ckad-netpol-external, labels: app=monitoring)"
echo ""
echo "Your task: Create 3 NetworkPolicies: backend-policy, database-policy, default-deny-ingress."
echo "See README.md for full instructions."
