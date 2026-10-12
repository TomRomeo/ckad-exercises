#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-helm"

echo "=== Exercise 11: Helm Basics ==="
echo "Setting up namespace: $NAMESPACE"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Check if helm is available
if command -v helm &>/dev/null; then
    echo "Helm is available: $(helm version --short 2>/dev/null || echo 'unknown version')"
else
    echo "WARNING: helm is not installed. Please install helm to complete this exercise."
    echo "See: https://helm.sh/docs/intro/install/"
fi

echo ""
echo "Setup complete!"
echo "Namespace '$NAMESPACE' is ready."
echo ""
echo "Your tasks:"
echo "1. Add the Bitnami Helm repo: https://charts.bitnami.com/bitnami"
echo "2. Install release 'my-nginx' using bitnami/nginx with replicaCount=2"
echo "3. Verify the release is deployed"
