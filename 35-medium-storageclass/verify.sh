#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-storageclass"
COURSE_DIR="/tmp/ckad-storageclass"
PASS=0
FAIL=0
TOTAL=6

echo "=== Verifying Exercise 35: StorageClass and a Pending PVC ==="
echo ""

# Check 1: StorageClass exists with correct provisioner
echo -n "Check 1/6 - StorageClass 'retain-sc' provisioner is custom-retainer: "
PROV=$(kubectl get storageclass retain-sc -o jsonpath='{.provisioner}' 2>/dev/null) || PROV=""
if [ "$PROV" = "custom-retainer" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (provisioner: '${PROV:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: reclaimPolicy Retain
echo -n "Check 2/6 - StorageClass reclaimPolicy is Retain: "
RECLAIM=$(kubectl get storageclass retain-sc -o jsonpath='{.reclaimPolicy}' 2>/dev/null) || RECLAIM=""
if [ "$RECLAIM" = "Retain" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (reclaimPolicy: '${RECLAIM:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: PVC exists with correct storageClassName
echo -n "Check 3/6 - PVC 'data-pvc' uses storageClassName retain-sc: "
SCN=$(kubectl get pvc data-pvc -n "$NAMESPACE" -o jsonpath='{.spec.storageClassName}' 2>/dev/null) || SCN=""
if [ "$SCN" = "retain-sc" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (storageClassName: '${SCN:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: PVC accessModes RWO and 3Gi request
echo -n "Check 4/6 - PVC accessMode ReadWriteOnce and request 3Gi: "
AM=$(kubectl get pvc data-pvc -n "$NAMESPACE" -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null) || AM=""
REQ=$(kubectl get pvc data-pvc -n "$NAMESPACE" -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null) || REQ=""
if [ "$AM" = "ReadWriteOnce" ] && [ "$REQ" = "3Gi" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (accessMode='${AM:-}', request='${REQ:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: PVC is Pending
echo -n "Check 5/6 - PVC status is Pending: "
PHASE=$(kubectl get pvc data-pvc -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null) || PHASE=""
if [ "$PHASE" = "Pending" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (phase: '${PHASE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 6: reason file exists and is non-empty
echo -n "Check 6/6 - $COURSE_DIR/pvc-reason exists and is non-empty: "
if [ -s "$COURSE_DIR/pvc-reason" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (file missing or empty)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
