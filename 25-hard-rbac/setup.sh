#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 25: RBAC - Roles and RoleBindings ==="
echo "Setting up namespace ckad-rbac..."

kubectl create namespace ckad-rbac --dry-run=client -o yaml | kubectl apply -f -

echo "Creating ServiceAccount 'dev-user'..."
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

echo ""
echo "Setup complete!"
echo ""
echo "Namespace: ckad-rbac"
echo "Pre-created: ServiceAccount 'dev-user'"
echo ""
echo "Tasks:"
echo "1. Create Role 'pod-reader' allowing get/list/watch on pods and pods/log"
echo "2. Create RoleBinding 'dev-user-pod-reader' binding pod-reader to dev-user SA"
echo "3. Create Role 'deploy-manager' allowing get/list/create/update/delete on deployments"
echo "4. Create RoleBinding 'dev-user-deploy-manager' binding deploy-manager to dev-user SA"
echo "5. Verify: dev-user can get pods and manage deployments, but NOT delete pods or create services"
