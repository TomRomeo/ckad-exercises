#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-secret"
PASS=0
FAIL=0
TOTAL=7

echo "=== Verifying Exercise 20: Secret Basics ==="
echo ""

# Check 1: Secret exists
echo -n "1. Secret 'db-credentials' exists: "
if kubectl get secret db-credentials -n "$NAMESPACE" &>/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
fi

# Check 2: Secret is type Opaque
echo -n "2. Secret type is Opaque: "
TYPE=$(kubectl get secret db-credentials -n "$NAMESPACE" -o jsonpath='{.type}' 2>/dev/null || true)
if [[ "$TYPE" == "Opaque" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$TYPE')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Secret has username and password keys
echo -n "3. Secret has 'username' and 'password' keys: "
KEYS=$(kubectl get secret db-credentials -n "$NAMESPACE" -o jsonpath='{.data}' 2>/dev/null || true)
if echo "$KEYS" | grep -q '"username"' && echo "$KEYS" | grep -q '"password"'; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (keys: $KEYS)"
  FAIL=$((FAIL + 1))
fi

# Check 4: Pod exists and is Running
echo -n "4. Pod 'secret-pod' exists and is Running: "
PHASE=$(kubectl get pod secret-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [[ "$PHASE" == "Running" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (phase: '$PHASE')"
  FAIL=$((FAIL + 1))
fi

# Check 5: Secret is mounted as volume at /etc/secrets
echo -n "5. Secret mounted as volume at /etc/secrets: "
SECRET_VOL_NAME=$(kubectl get pod secret-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes}' 2>/dev/null | python3 -c "
import json, sys
try:
    vols = json.load(sys.stdin)
    for v in vols:
        s = v.get('secret', {})
        if s.get('secretName') == 'db-credentials':
            print(v['name'])
            break
except: pass
" 2>/dev/null || true)
if [[ -z "$SECRET_VOL_NAME" ]]; then
  echo "FAIL (no volume referencing secret 'db-credentials' found)"
  FAIL=$((FAIL + 1))
else
  MOUNT_PATH=$(kubectl get pod secret-pod -n "$NAMESPACE" -o json 2>/dev/null | python3 -c "
import json, sys
try:
    pod = json.load(sys.stdin)
    for c in pod['spec']['containers']:
        for vm in c.get('volumeMounts', []):
            if vm['name'] == '$SECRET_VOL_NAME':
                print(vm['mountPath'])
                break
except: pass
" 2>/dev/null || true)
  if [[ "$MOUNT_PATH" == "/etc/secrets" ]]; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL (mountPath: '${MOUNT_PATH:-not found}' for volume '$SECRET_VOL_NAME')"
    FAIL=$((FAIL + 1))
  fi
fi

# Check 6: File /etc/secrets/username exists
echo -n "6. File /etc/secrets/username exists in container: "
if kubectl exec secret-pod -n "$NAMESPACE" -- cat /etc/secrets/username &>/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
fi

# Check 7: File /etc/secrets/password exists
echo -n "7. File /etc/secrets/password exists in container: "
if kubectl exec secret-pod -n "$NAMESPACE" -- cat /etc/secrets/password &>/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
