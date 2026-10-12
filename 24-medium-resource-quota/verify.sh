#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-quota"
PASS=0
FAIL=0
TOTAL=8

echo "=== Verifying Exercise 24: ResourceQuota and LimitRange ==="
echo ""

# Check 1: ResourceQuota exists
echo -n "1. ResourceQuota 'compute-quota' exists: "
if kubectl get resourcequota compute-quota -n "$NAMESPACE" &>/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
fi

# Check 2: ResourceQuota has correct hard limits
echo -n "2. ResourceQuota has correct hard limits: "
REQ_CPU=$(kubectl get resourcequota compute-quota -n "$NAMESPACE" -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null || true)
REQ_MEM=$(kubectl get resourcequota compute-quota -n "$NAMESPACE" -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null || true)
LIM_CPU=$(kubectl get resourcequota compute-quota -n "$NAMESPACE" -o jsonpath='{.spec.hard.limits\.cpu}' 2>/dev/null || true)
LIM_MEM=$(kubectl get resourcequota compute-quota -n "$NAMESPACE" -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null || true)
PODS=$(kubectl get resourcequota compute-quota -n "$NAMESPACE" -o jsonpath='{.spec.hard.pods}' 2>/dev/null || true)
if [[ "$REQ_CPU" == "1" ]] && [[ "$REQ_MEM" == "1Gi" ]] && [[ "$LIM_CPU" == "2" ]] && [[ "$LIM_MEM" == "2Gi" ]] && [[ "$PODS" == "5" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (req.cpu=$REQ_CPU, req.mem=$REQ_MEM, lim.cpu=$LIM_CPU, lim.mem=$LIM_MEM, pods=$PODS)"
  FAIL=$((FAIL + 1))
fi

# Check 3: LimitRange exists
echo -n "3. LimitRange 'default-limits' exists: "
if kubectl get limitrange default-limits -n "$NAMESPACE" &>/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
fi

# Check 4: LimitRange has correct defaults
echo -n "4. LimitRange has correct default limits and requests: "
DEF_CPU=$(kubectl get limitrange default-limits -n "$NAMESPACE" -o jsonpath='{.spec.limits[0].default.cpu}' 2>/dev/null || true)
DEF_MEM=$(kubectl get limitrange default-limits -n "$NAMESPACE" -o jsonpath='{.spec.limits[0].default.memory}' 2>/dev/null || true)
DEFREQ_CPU=$(kubectl get limitrange default-limits -n "$NAMESPACE" -o jsonpath='{.spec.limits[0].defaultRequest.cpu}' 2>/dev/null || true)
DEFREQ_MEM=$(kubectl get limitrange default-limits -n "$NAMESPACE" -o jsonpath='{.spec.limits[0].defaultRequest.memory}' 2>/dev/null || true)
if [[ "$DEF_CPU" == "200m" ]] && [[ "$DEF_MEM" == "256Mi" ]] && [[ "$DEFREQ_CPU" == "100m" ]] && [[ "$DEFREQ_MEM" == "128Mi" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (default: cpu=$DEF_CPU,mem=$DEF_MEM; defaultRequest: cpu=$DEFREQ_CPU,mem=$DEFREQ_MEM)"
  FAIL=$((FAIL + 1))
fi

# Check 5: Pod quota-pod exists and is Running
echo -n "5. Pod 'quota-pod' exists and is Running: "
PHASE=$(kubectl get pod quota-pod -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [[ "$PHASE" == "Running" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (phase: '$PHASE')"
  FAIL=$((FAIL + 1))
fi

# Check 6: Pod has correct resource requests
echo -n "6. Pod has correct resource requests (cpu=150m, memory=200Mi): "
POD_REQ_CPU=$(kubectl get pod quota-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.requests.cpu}' 2>/dev/null || true)
POD_REQ_MEM=$(kubectl get pod quota-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.requests.memory}' 2>/dev/null || true)
if [[ "$POD_REQ_CPU" == "150m" ]] && [[ "$POD_REQ_MEM" == "200Mi" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (cpu=$POD_REQ_CPU, mem=$POD_REQ_MEM)"
  FAIL=$((FAIL + 1))
fi

# Check 7: Pod has correct resource limits
echo -n "7. Pod has correct resource limits (cpu=300m, memory=400Mi): "
POD_LIM_CPU=$(kubectl get pod quota-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.limits.cpu}' 2>/dev/null || true)
POD_LIM_MEM=$(kubectl get pod quota-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.limits.memory}' 2>/dev/null || true)
if [[ "$POD_LIM_CPU" == "300m" ]] && [[ "$POD_LIM_MEM" == "400Mi" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (cpu=$POD_LIM_CPU, mem=$POD_LIM_MEM)"
  FAIL=$((FAIL + 1))
fi

# Check 8: ResourceQuota shows used resources > 0
echo -n "8. ResourceQuota shows used resources > 0: "
USED_PODS=$(kubectl get resourcequota compute-quota -n "$NAMESPACE" -o jsonpath='{.status.used.pods}' 2>/dev/null || true)
if [[ -n "$USED_PODS" ]] && [[ "$USED_PODS" != "0" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (used pods: '$USED_PODS')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
