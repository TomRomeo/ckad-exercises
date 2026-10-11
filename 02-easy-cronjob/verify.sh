#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-cronjob"
PASS=0
FAIL=0
TOTAL=6

echo "=== Verifying Exercise 02: CronJob Creation ==="
echo ""

# Check 1: CronJob exists
echo -n "Check 1/6 - CronJob 'date-printer' exists: "
if kubectl get cronjob date-printer -n "$NAMESPACE" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (CronJob not found)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Schedule is */1 * * * *
echo -n "Check 2/6 - Schedule is '*/1 * * * *': "
SCHEDULE=$(kubectl get cronjob date-printer -n "$NAMESPACE" -o jsonpath='{.spec.schedule}' 2>/dev/null) || SCHEDULE=""
if [ "$SCHEDULE" = "*/1 * * * *" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (schedule: '${SCHEDULE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Image is busybox:1.36
echo -n "Check 3/6 - Image is busybox:1.36: "
IMAGE=$(kubectl get cronjob date-printer -n "$NAMESPACE" -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null) || IMAGE=""
if [ "$IMAGE" = "busybox:1.36" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (image: '${IMAGE:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: successfulJobsHistoryLimit is 3
echo -n "Check 4/6 - successfulJobsHistoryLimit is 3: "
SUCCESS_LIMIT=$(kubectl get cronjob date-printer -n "$NAMESPACE" -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null) || SUCCESS_LIMIT=""
if [ "$SUCCESS_LIMIT" = "3" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (successfulJobsHistoryLimit: '${SUCCESS_LIMIT:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: failedJobsHistoryLimit is 1
echo -n "Check 5/6 - failedJobsHistoryLimit is 1: "
FAILED_LIMIT=$(kubectl get cronjob date-printer -n "$NAMESPACE" -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null) || FAILED_LIMIT=""
if [ "$FAILED_LIMIT" = "1" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (failedJobsHistoryLimit: '${FAILED_LIMIT:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 6: restartPolicy is Never
echo -n "Check 6/6 - restartPolicy is Never: "
RESTART=$(kubectl get cronjob date-printer -n "$NAMESPACE" -o jsonpath='{.spec.jobTemplate.spec.template.spec.restartPolicy}' 2>/dev/null) || RESTART=""
if [ "$RESTART" = "Never" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (restartPolicy: '${RESTART:-not found}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
