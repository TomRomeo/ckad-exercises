#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-pod-design"
PASS=0
FAIL=0
TOTAL=5

echo "=== Verifying Exercise 01: Pod Design Basics ==="
echo ""

# Check 1: Pod exists and is Running
echo -n "Check 1/5 - Pod 'web-pod' exists and is Running: "
POD_STATUS=$(kubectl get pod web-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null) || POD_STATUS=""
if [ "$POD_STATUS" = "Running" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (status: '${POD_STATUS:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: Image is nginx:1.25
echo -n "Check 2/5 - Image is nginx:1.25: "
IMAGE=$(kubectl get pod web-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].image}' 2>/dev/null) || IMAGE=""
if [ "$IMAGE" = "nginx:1.25" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (image: '${IMAGE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Labels app=web and tier=frontend
echo -n "Check 3/5 - Labels app=web and tier=frontend: "
LABEL_APP=$(kubectl get pod web-pod -n "$NAMESPACE" -o jsonpath='{.metadata.labels.app}' 2>/dev/null) || LABEL_APP=""
LABEL_TIER=$(kubectl get pod web-pod -n "$NAMESPACE" -o jsonpath='{.metadata.labels.tier}' 2>/dev/null) || LABEL_TIER=""
if [ "$LABEL_APP" = "web" ] && [ "$LABEL_TIER" = "frontend" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (app='${LABEL_APP:-}', tier='${LABEL_TIER:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: Annotation description=CKAD practice pod
echo -n "Check 4/5 - Annotation 'description=CKAD practice pod': "
ANNOTATION=$(kubectl get pod web-pod -n "$NAMESPACE" -o jsonpath='{.metadata.annotations.description}' 2>/dev/null) || ANNOTATION=""
if [ "$ANNOTATION" = "CKAD practice pod" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (description='${ANNOTATION:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: Container port 80 is defined
echo -n "Check 5/5 - Container port 80 defined: "
PORT=$(kubectl get pod web-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].ports[0].containerPort}' 2>/dev/null) || PORT=""
if [ "$PORT" = "80" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (port: '${PORT:-not found}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
