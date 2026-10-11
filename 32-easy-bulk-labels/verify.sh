#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-labels"
PASS=0
FAIL=0
TOTAL=4

echo "=== Verifying Exercise 32: Bulk Labels and Annotations by Selector ==="
echo ""

get_label() {
  kubectl get pod "$1" -n "$NAMESPACE" -o jsonpath='{.metadata.labels.protected}' 2>/dev/null || true
}
get_anno() {
  kubectl get pod "$1" -n "$NAMESPACE" -o jsonpath='{.metadata.annotations.protected}' 2>/dev/null || true
}

# Check 1: worker + runner pods are labelled protected=true
echo -n "Check 1/4 - worker-1, worker-2, runner-1 have label protected=true: "
if [ "$(get_label worker-1)" = "true" ] && [ "$(get_label worker-2)" = "true" ] && [ "$(get_label runner-1)" = "true" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (worker-1='$(get_label worker-1)', worker-2='$(get_label worker-2)', runner-1='$(get_label runner-1)')"
  FAIL=$((FAIL + 1))
fi

# Check 2: other pods are NOT labelled protected
echo -n "Check 2/4 - other-1, other-2 are NOT labelled protected: "
if [ -z "$(get_label other-1)" ] && [ -z "$(get_label other-2)" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (other-1='$(get_label other-1)', other-2='$(get_label other-2)')"
  FAIL=$((FAIL + 1))
fi

# Check 3: protected pods carry the annotation
echo -n "Check 3/4 - protected pods annotated 'protected=do not delete this pod': "
EXPECT="do not delete this pod"
if [ "$(get_anno worker-1)" = "$EXPECT" ] && [ "$(get_anno worker-2)" = "$EXPECT" ] && [ "$(get_anno runner-1)" = "$EXPECT" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (worker-1='$(get_anno worker-1)', runner-1='$(get_anno runner-1)')"
  FAIL=$((FAIL + 1))
fi

# Check 4: other pods do NOT carry the annotation
echo -n "Check 4/4 - other pods are NOT annotated protected: "
if [ -z "$(get_anno other-1)" ] && [ -z "$(get_anno other-2)" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (other-1='$(get_anno other-1)', other-2='$(get_anno other-2)')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
