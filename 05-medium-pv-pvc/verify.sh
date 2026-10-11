#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-volumes"
PASS=0
FAIL=0
TOTAL=4

echo "=== Verifying Exercise 05: PersistentVolume and PersistentVolumeClaim ==="
echo ""

# Check 1: PV 'ckad-pv' exists with correct spec
echo -n "Check 1/4 - PV 'ckad-pv' (1Gi, RWO, hostPath=/tmp/ckad-data, storageClass=manual): "
PV_CAP=$(kubectl get pv ckad-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null) || PV_CAP=""
PV_ACCESS=$(kubectl get pv ckad-pv -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null) || PV_ACCESS=""
PV_PATH=$(kubectl get pv ckad-pv -o jsonpath='{.spec.hostPath.path}' 2>/dev/null) || PV_PATH=""
PV_SC=$(kubectl get pv ckad-pv -o jsonpath='{.spec.storageClassName}' 2>/dev/null) || PV_SC=""
if [ "$PV_CAP" = "1Gi" ] && [ "$PV_ACCESS" = "ReadWriteOnce" ] && [ "$PV_PATH" = "/tmp/ckad-data" ] && [ "$PV_SC" = "manual" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (capacity='${PV_CAP:-}', access='${PV_ACCESS:-}', path='${PV_PATH:-}', sc='${PV_SC:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: PVC 'ckad-pvc' exists and is Bound
echo -n "Check 2/4 - PVC 'ckad-pvc' exists and is Bound: "
PVC_STATUS=$(kubectl get pvc ckad-pvc -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null) || PVC_STATUS=""
PVC_SC=$(kubectl get pvc ckad-pvc -n "$NAMESPACE" -o jsonpath='{.spec.storageClassName}' 2>/dev/null) || PVC_SC=""
PVC_ACCESS=$(kubectl get pvc ckad-pvc -n "$NAMESPACE" -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null) || PVC_ACCESS=""
PVC_REQ=$(kubectl get pvc ckad-pvc -n "$NAMESPACE" -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null) || PVC_REQ=""
if [ "$PVC_STATUS" = "Bound" ] && [ "$PVC_SC" = "manual" ] && [ "$PVC_ACCESS" = "ReadWriteOnce" ] && [ "$PVC_REQ" = "500Mi" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status='${PVC_STATUS:-}', sc='${PVC_SC:-}', access='${PVC_ACCESS:-}', request='${PVC_REQ:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Pod 'pv-pod' exists and mounts PVC at /data
echo -n "Check 3/4 - Pod 'pv-pod' mounts PVC 'ckad-pvc' at /data: "
POD_PVC=$(kubectl get pod pv-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="data-volume")].persistentVolumeClaim.claimName}' 2>/dev/null) || POD_PVC=""
POD_MOUNT=$(kubectl get pod pv-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="data-volume")].mountPath}' 2>/dev/null) || POD_MOUNT=""
if [ "$POD_PVC" = "ckad-pvc" ] && [ "$POD_MOUNT" = "/data" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (pvc='${POD_PVC:-not found}', mountPath='${POD_MOUNT:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: Pod is Running
echo -n "Check 4/4 - Pod 'pv-pod' is Running: "
POD_STATUS=$(kubectl get pod pv-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null) || POD_STATUS=""
if [ "$POD_STATUS" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: '${POD_STATUS:-not found}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
