#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-multi-container"
PASS=0
FAIL=0
TOTAL=7

echo "=== Verifying Exercise 03: Multi-Container Pod (Sidecar Pattern) ==="
echo ""

# Check 1: Pod exists and is Running
echo -n "Check 1/$TOTAL - Pod 'sidecar-pod' exists and is Running: "
POD_STATUS=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null) || POD_STATUS=""
if [ "$POD_STATUS" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: '${POD_STATUS:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: Pod has exactly 1 main container named 'app'
echo -n "Check 2/$TOTAL - Pod has main container named 'app': "
MAIN_NAMES=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null) || MAIN_NAMES=""
MAIN_COUNT=$(echo "$MAIN_NAMES" | wc -w | tr -d ' ')
if [ "$MAIN_COUNT" = "1" ] && echo "$MAIN_NAMES" | grep -qw "app"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (main containers: '${MAIN_NAMES:-not found}', count: $MAIN_COUNT)"
  FAIL=$((FAIL + 1))
fi

# Check 3: Sidecar 'sidecar' is defined as a native sidecar in initContainers
echo -n "Check 3/$TOTAL - Sidecar 'sidecar' defined in initContainers: "
INIT_NAMES=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null) || INIT_NAMES=""
if echo "$INIT_NAMES" | grep -qw "sidecar"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (initContainers: '${INIT_NAMES:-none found}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: Sidecar has restartPolicy: Always (native sidecar)
echo -n "Check 4/$TOTAL - Sidecar has restartPolicy=Always: "
RESTART_POLICY=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="sidecar")].restartPolicy}' 2>/dev/null) || RESTART_POLICY=""
if [ "$RESTART_POLICY" = "Always" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (restartPolicy: '${RESTART_POLICY:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: Both containers use busybox:1.36
echo -n "Check 5/$TOTAL - Both containers use busybox:1.36: "
APP_IMAGE=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].image}' 2>/dev/null) || APP_IMAGE=""
SIDECAR_IMAGE=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="sidecar")].image}' 2>/dev/null) || SIDECAR_IMAGE=""
if [ "$APP_IMAGE" = "busybox:1.36" ] && [ "$SIDECAR_IMAGE" = "busybox:1.36" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (app image: '${APP_IMAGE:-not found}', sidecar image: '${SIDECAR_IMAGE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 6: Volume 'log-volume' of type emptyDir exists
echo -n "Check 6/$TOTAL - Volume 'log-volume' (emptyDir) exists: "
VOL_NAME=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="log-volume")].name}' 2>/dev/null) || VOL_NAME=""
VOL_EMPTY=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="log-volume")].emptyDir}' 2>/dev/null) || VOL_EMPTY=""
if [ "$VOL_NAME" = "log-volume" ] && [ -n "$VOL_EMPTY" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (volume name: '${VOL_NAME:-not found}', emptyDir: '${VOL_EMPTY:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 7: Both containers mount the volume at /var/log
echo -n "Check 7/$TOTAL - Both containers mount 'log-volume' at /var/log: "
APP_MOUNT=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="log-volume")].mountPath}' 2>/dev/null) || APP_MOUNT=""
SIDECAR_MOUNT=$(kubectl get pod sidecar-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="sidecar")].volumeMounts[?(@.name=="log-volume")].mountPath}' 2>/dev/null) || SIDECAR_MOUNT=""
if [ "$APP_MOUNT" = "/var/log" ] && [ "$SIDECAR_MOUNT" = "/var/log" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (app mount: '${APP_MOUNT:-not found}', sidecar mount: '${SIDECAR_MOUNT:-not found}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
