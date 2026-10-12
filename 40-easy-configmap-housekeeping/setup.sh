#!/bin/bash
set -euo pipefail

# Safety guard: confirm the target cluster before creating/deleting resources.
source "$(dirname "$0")/../scripts/cluster-guard.sh"
ckad_confirm_cluster

NS1="ckad-housekeeping1"
NS2="ckad-housekeeping2"
COURSE_DIR="/tmp/ckad-housekeeping"

echo "=== Setting up Exercise 40: ConfigMap Housekeeping by Label ==="

kubectl create namespace "$NS1" --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace "$NS2" --dry-run=client -o yaml | kubectl apply -f -

# Clean any leftovers from previous runs so counts are deterministic
kubectl delete cm -n "$NS1" -l managed-by=ckad40 --ignore-not-found >/dev/null 2>&1 || true
kubectl delete cm -n "$NS2" -l managed-by=ckad40 --ignore-not-found >/dev/null 2>&1 || true

# NS1: exactly 3 cache ConfigMaps + 2 non-cache
for n in cache-a cache-b cache-c; do
  kubectl create cm "$n" -n "$NS1" --from-literal=k=v --dry-run=client -o yaml | kubectl apply -f -
  kubectl label cm "$n" -n "$NS1" purpose=cache managed-by=ckad40 --overwrite >/dev/null
done
for n in config-x logs-y; do
  kubectl create cm "$n" -n "$NS1" --from-literal=k=v --dry-run=client -o yaml | kubectl apply -f -
  kubectl label cm "$n" -n "$NS1" purpose=other managed-by=ckad40 --overwrite >/dev/null
done

# NS2: 4 expired ConfigMaps + 2 active (must survive)
for n in old-1 old-2 old-3 old-4; do
  kubectl create cm "$n" -n "$NS2" --from-literal=k=v --dry-run=client -o yaml | kubectl apply -f -
  kubectl label cm "$n" -n "$NS2" purpose=expired managed-by=ckad40 --overwrite >/dev/null
done
for n in active-1 active-2; do
  kubectl create cm "$n" -n "$NS2" --from-literal=k=v --dry-run=client -o yaml | kubectl apply -f -
  kubectl label cm "$n" -n "$NS2" purpose=active managed-by=ckad40 --overwrite >/dev/null
done

mkdir -p "$COURSE_DIR"

echo ""
echo "Namespaces '$NS1' and '$NS2' are ready with labelled ConfigMaps."
echo "Output directory: $COURSE_DIR"
echo "Your task: count cache ConfigMaps in $NS1, delete expired ConfigMaps in $NS2 (see README.md)."
echo "Run verify.sh when you are done."
