#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Exercise 22: Security Context ==="
echo "Setting up namespace ckad-secctx..."

kubectl create namespace ckad-secctx --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Setup complete!"
echo ""
echo "Namespace: ckad-secctx"
echo ""
echo "Tasks:"
echo "1. Create pod 'secure-pod' (busybox:1.36, container: secure-container, command: sleep 3600)"
echo "2. Pod-level: runAsUser=1000, runAsGroup=3000, fsGroup=2000"
echo "3. Container-level: allowPrivilegeEscalation=false, readOnlyRootFilesystem=true"
echo "4. Add emptyDir volume 'tmp-vol' mounted at /tmp"
