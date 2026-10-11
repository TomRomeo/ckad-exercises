#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-hpa"
PASS=0
FAIL=0
TOTAL=5

echo "=== Verifying Exercise 34: Fix a Deprecated HorizontalPodAutoscaler ==="
echo ""

# Check 1: HPA exists and targets api-app
echo -n "Check 1/5 - HPA 'api-app' exists and targets Deployment api-app: "
TARGET=$(kubectl get hpa api-app -n "$NAMESPACE" -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null) || TARGET=""
KIND=$(kubectl get hpa api-app -n "$NAMESPACE" -o jsonpath='{.spec.scaleTargetRef.kind}' 2>/dev/null) || KIND=""
if [ "$TARGET" = "api-app" ] && [ "$KIND" = "Deployment" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (target='${TARGET:-}', kind='${KIND:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: Stored as autoscaling/v2 (served, non-deprecated)
echo -n "Check 2/5 - HPA served under autoscaling/v2: "
if kubectl get hpa.v2.autoscaling api-app -n "$NAMESPACE" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (not retrievable via autoscaling/v2)"
  FAIL=$((FAIL + 1))
fi

# Check 3: minReplicas == 2
echo -n "Check 3/5 - minReplicas is 2: "
MIN=$(kubectl get hpa api-app -n "$NAMESPACE" -o jsonpath='{.spec.minReplicas}' 2>/dev/null) || MIN=""
if [ "$MIN" = "2" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (minReplicas: '${MIN:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: maxReplicas == 5
echo -n "Check 4/5 - maxReplicas is 5: "
MAX=$(kubectl get hpa api-app -n "$NAMESPACE" -o jsonpath='{.spec.maxReplicas}' 2>/dev/null) || MAX=""
if [ "$MAX" = "5" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (maxReplicas: '${MAX:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: memory metric at averageUtilization 80 exists (alongside cpu)
echo -n "Check 5/5 - memory metric with averageUtilization 80 present: "
MEM=$(kubectl get hpa api-app -n "$NAMESPACE" -o jsonpath='{.spec.metrics[?(@.resource.name=="memory")].resource.target.averageUtilization}' 2>/dev/null) || MEM=""
CPU=$(kubectl get hpa api-app -n "$NAMESPACE" -o jsonpath='{.spec.metrics[?(@.resource.name=="cpu")].resource.name}' 2>/dev/null) || CPU=""
if [ "$MEM" = "80" ] && [ "$CPU" = "cpu" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (memory avgUtil='${MEM:-missing}', cpu present='${CPU:-no}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
