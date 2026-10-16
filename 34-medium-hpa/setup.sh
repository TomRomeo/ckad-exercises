#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="ckad-hpa"
COURSE_DIR="/tmp/ckad-hpa"

echo "=== Setting up Exercise 34: Fix a Deprecated HorizontalPodAutoscaler ==="

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

mkdir -p "$COURSE_DIR"
cat > "$COURSE_DIR/hpa.yaml" <<'EOF'
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: api-app
  namespace: ckad-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-app
  minReplicas: 1
  maxReplicas: 3
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
EOF

echo ""
echo "Namespace '$NAMESPACE' is ready with Deployment api-app."
echo "A broken HPA manifest is at $COURSE_DIR/hpa.yaml (deprecated apiVersion)."
echo "Your task: fix and extend it as described in README.md, then apply it."
echo "Run verify.sh when you are done."
