#!/bin/bash
set -euo pipefail

echo "============================================"
echo "  CKAD Exercise Cleanup"
echo "============================================"
echo ""
echo "This will delete ALL exercise namespaces from the cluster."
echo ""

NAMESPACES=(
    ckad-pod-design
    ckad-cronjob
    ckad-multi-container
    ckad-init-container
    ckad-volumes
    ckad-adv-pod
    ckad-deploy-basics
    ckad-rolling-update
    ckad-rollback
    ckad-deploy-strategy
    ckad-helm
    ckad-canary
    ckad-logs
    ckad-liveness
    ckad-readiness
    ckad-debug
    ckad-startup
    ckad-troubleshoot
    ckad-configmap
    ckad-secret
    ckad-resources
    ckad-secctx
    ckad-sa
    ckad-quota
    ckad-rbac
    ckad-svc-clusterip
    ckad-svc-nodeport
    ckad-netpol
    ckad-ingress
    ckad-netpol-adv
    ckad-netpol-external
)

# Also clean up cluster-scoped resources
echo "Cleaning up PersistentVolumes..."
kubectl delete pv ckad-pv 2>/dev/null && echo "  Deleted PV ckad-pv" || echo "  PV ckad-pv not found (OK)"

echo ""
echo "Cleaning up namespaces..."
for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" 2>/dev/null >/dev/null; then
        echo "  Deleting namespace: $ns"
        kubectl delete namespace "$ns" --wait=false 2>/dev/null || true
    else
        echo "  Namespace $ns not found (OK)"
    fi
done

# Clean up Helm repos
if command -v helm &>/dev/null; then
    echo ""
    echo "Cleaning up Helm repositories..."
    helm repo remove bitnami 2>/dev/null && echo "  Removed Helm repo bitnami" || echo "  Helm repo bitnami not found (OK)"
fi

# Clean up temp files
echo ""
echo "Cleaning up temp files..."
rm -f /tmp/ckad-logs-output.txt 2>/dev/null && echo "  Removed /tmp/ckad-logs-output.txt" || true

echo ""
echo "============================================"
echo "  Cleanup Complete"
echo "============================================"
echo ""
echo "Note: Namespace deletion may take a moment to"
echo "fully complete in the background."
