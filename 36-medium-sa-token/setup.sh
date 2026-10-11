#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-sa-token"
COURSE_DIR="/tmp/ckad-sa-token"

echo "=== Setting up Exercise 36: Decode a ServiceAccount Token ==="

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# ServiceAccount
kubectl create serviceaccount backend-sa-v2 -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Manually-created, long-lived token Secret bound to the ServiceAccount.
# The control plane's token controller populates data.token for this Secret.
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: backend-sa-v2-token
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: backend-sa-v2
type: kubernetes.io/service-account-token
EOF

mkdir -p "$COURSE_DIR"

# Give the token controller a moment to inject the token.
echo "Waiting for the token to be populated..."
for i in $(seq 1 15); do
  TOKEN=$(kubectl get secret backend-sa-v2-token -n "$NAMESPACE" -o jsonpath='{.data.token}' 2>/dev/null || true)
  if [ -n "$TOKEN" ]; then
    break
  fi
  sleep 1
done

echo ""
echo "Namespace '$NAMESPACE' is ready with ServiceAccount backend-sa-v2 and its token Secret."
echo "Output directory: $COURSE_DIR"
echo "Your task: write the decoded token to $COURSE_DIR/token (see README.md)."
echo "Run verify.sh when you are done."
