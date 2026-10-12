#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

NAMESPACE="ckad-kustomize"
KDIR="/tmp/ckad-kustomize"

echo "=== Setting up Exercise 39: Canary Rollout with Kustomize ==="

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

rm -rf "$KDIR"
mkdir -p "$KDIR"

cat > "$KDIR/deployment-main.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-main
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
      track: main
  template:
    metadata:
      labels:
        app: web
        track: main
    spec:
      containers:
        - name: web
          image: nginx:1.25-alpine
          ports:
            - containerPort: 80
EOF

cat > "$KDIR/deployment-canary.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
      track: canary
  template:
    metadata:
      labels:
        app: web
        track: canary
    spec:
      containers:
        - name: web
          image: nginx:1.26-alpine
          ports:
            - containerPort: 80
EOF

cat > "$KDIR/service.yaml" <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
EOF

cat > "$KDIR/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ckad-kustomize
resources:
  - deployment-main.yaml
  - deployment-canary.yaml
  - service.yaml
replicas:
  - name: web-main
    count: 1
  - name: web-canary
    count: 1
EOF

echo ""
echo "Namespace '$NAMESPACE' is ready. Kustomize base written to $KDIR."
echo "Your task: edit the replica counts to total 10 pods with 20% canary, then apply with -k."
echo "Run verify.sh when you are done."
