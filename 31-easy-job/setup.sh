#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-job"

echo "=== Setting up Exercise 31: Job with Completions and Parallelism ==="

# Create namespace (idempotent)
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Namespace '$NAMESPACE' is ready."
echo ""
echo "Your task: Create a Job 'batch-job' with 3 completions, 2 parallel, labelled pods."
echo "Run verify.sh when you are done."
