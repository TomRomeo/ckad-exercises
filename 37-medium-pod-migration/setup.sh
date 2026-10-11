#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Setting up Exercise 37: Find a Pod by Label and Move It ==="

kubectl create namespace ckad-staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ckad-shop --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCRIPT_DIR/setup-resources.yaml"

echo ""
echo "Namespaces 'ckad-staging' (source) and 'ckad-shop' (target) are ready."
echo "One pod in ckad-staging carries label system=web-shop. Find it and move it."
echo "Run verify.sh when you are done."
