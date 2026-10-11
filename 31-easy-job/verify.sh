#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-job"
PASS=0
FAIL=0
TOTAL=6

echo "=== Verifying Exercise 31: Job with Completions and Parallelism ==="
echo ""

# Check 1: Job exists
echo -n "Check 1/6 - Job 'batch-job' exists: "
if kubectl get job batch-job -n "$NAMESPACE" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (Job not found)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Container name and image
echo -n "Check 2/6 - Container 'batch-job-container' uses image busybox:1.36: "
CNAME=$(kubectl get job batch-job -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null) || CNAME=""
CIMG=$(kubectl get job batch-job -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null) || CIMG=""
if [ "$CNAME" = "batch-job-container" ] && [ "$CIMG" = "busybox:1.36" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (name='${CNAME:-}', image='${CIMG:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: completions == 3
echo -n "Check 3/6 - completions is 3: "
COMP=$(kubectl get job batch-job -n "$NAMESPACE" -o jsonpath='{.spec.completions}' 2>/dev/null) || COMP=""
if [ "$COMP" = "3" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (completions: '${COMP:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: parallelism == 2
echo -n "Check 4/6 - parallelism is 2: "
PAR=$(kubectl get job batch-job -n "$NAMESPACE" -o jsonpath='{.spec.parallelism}' 2>/dev/null) || PAR=""
if [ "$PAR" = "2" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (parallelism: '${PAR:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: pod template label id=awesome-job
echo -n "Check 5/6 - pod template label id=awesome-job: "
LABEL=$(kubectl get job batch-job -n "$NAMESPACE" -o jsonpath='{.spec.template.metadata.labels.id}' 2>/dev/null) || LABEL=""
if [ "$LABEL" = "awesome-job" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (id label: '${LABEL:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 6: command runs the sleep/echo via shell
echo -n "Check 6/6 - container command runs 'sleep 2 && echo done': "
CMD=$(kubectl get job batch-job -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].command}{.spec.template.spec.containers[0].args}' 2>/dev/null) || CMD=""
if echo "$CMD" | grep -q "sleep 2" && echo "$CMD" | grep -q "echo done"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (command: '${CMD:-not found}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
