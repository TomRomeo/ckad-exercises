#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-secctx"
PASS=0
FAIL=0
TOTAL=8

echo "=== Verifying Exercise 22: Security Context ==="
echo ""

# Check 1: Pod exists and is Running
echo -n "1. Pod 'secure-pod' exists and is Running: "
PHASE=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [[ "$PHASE" == "Running" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (phase: '$PHASE')"
  FAIL=$((FAIL + 1))
fi

# Check 2: runAsUser is 1000
echo -n "2. runAsUser is 1000: "
VAL=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null || true)
if [[ "$VAL" == "1000" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 3: runAsGroup is 3000
echo -n "3. runAsGroup is 3000: "
VAL=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.spec.securityContext.runAsGroup}' 2>/dev/null || true)
if [[ "$VAL" == "3000" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 4: fsGroup is 2000
echo -n "4. fsGroup is 2000: "
VAL=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.spec.securityContext.fsGroup}' 2>/dev/null || true)
if [[ "$VAL" == "2000" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 5: allowPrivilegeEscalation is false
echo -n "5. allowPrivilegeEscalation is false: "
VAL=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null || true)
if [[ "$VAL" == "false" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 6: readOnlyRootFilesystem is true
echo -n "6. readOnlyRootFilesystem is true: "
VAL=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null || true)
if [[ "$VAL" == "true" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$VAL')"
  FAIL=$((FAIL + 1))
fi

# Check 7: emptyDir volume mounted at /tmp
echo -n "7. emptyDir volume 'tmp-vol' mounted at /tmp: "
MOUNT_PATH=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="tmp-vol")].mountPath}' 2>/dev/null || true)
VOL_TYPE=$(kubectl get pod secure-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="tmp-vol")].emptyDir}' 2>/dev/null || true)
if [[ "$MOUNT_PATH" == "/tmp" ]] && [[ -n "$VOL_TYPE" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (mountPath: '$MOUNT_PATH', emptyDir: '$VOL_TYPE')"
  FAIL=$((FAIL + 1))
fi

# Check 8: Container runs as user 1000
echo -n "8. Container runs as user 1000 (exec id): "
ID_OUTPUT=$(kubectl exec secure-pod -n "$NAMESPACE" -- id 2>/dev/null || true)
if echo "$ID_OUTPUT" | grep -q "uid=1000"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (id output: '$ID_OUTPUT')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
