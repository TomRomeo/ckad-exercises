#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-bluegreen"
PASS=0
FAIL=0
TOTAL=4

echo "=== Verifying Exercise 33: Blue-Green Deployment Cutover ==="
echo ""

# Check 1: web-green image updated
echo -n "Check 1/4 - web-green image is nginx:1.31-alpine: "
GIMG=$(kubectl get deploy web-green -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null) || GIMG=""
if [ "$GIMG" = "nginx:1.31-alpine" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (image: '${GIMG:-not found}')"
  FAIL=$((FAIL + 1))
fi

# Check 2: web-green deployment still exists (not deleted)
echo -n "Check 2/4 - web-green Deployment still exists: "
if kubectl get deploy web-green -n "$NAMESPACE" 2>/dev/null >/dev/null; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (web-green was deleted)"
  FAIL=$((FAIL + 1))
fi

# Check 3: Service selector targets blue only
echo -n "Check 3/4 - web-svc selector targets version=blue: "
SELVER=$(kubectl get svc web-svc -n "$NAMESPACE" -o jsonpath='{.spec.selector.version}' 2>/dev/null) || SELVER=""
if [ "$SELVER" = "blue" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (selector.version: '${SELVER:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: Service endpoints point only to blue pods
echo -n "Check 4/4 - web-svc endpoints only include blue pods: "
# Gather endpoint IPs
EP_IPS=$(kubectl get endpoints web-svc -n "$NAMESPACE" -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | tr ' ' '\n' | sort -u | grep -v '^$' || true)
# Gather green pod IPs
GREEN_IPS=$(kubectl get pods -n "$NAMESPACE" -l app=web,version=green -o jsonpath='{.items[*].status.podIP}' 2>/dev/null | tr ' ' '\n' | sort -u | grep -v '^$' || true)
BLUE_COUNT=$(kubectl get pods -n "$NAMESPACE" -l app=web,version=blue --field-selector=status.phase=Running 2>/dev/null | grep -c Running || true)
OVERLAP=""
if [ -n "$EP_IPS" ] && [ -n "$GREEN_IPS" ]; then
  OVERLAP=$(comm -12 <(echo "$EP_IPS") <(echo "$GREEN_IPS") || true)
fi
EP_COUNT=$(echo "$EP_IPS" | grep -c '.' || true)
if [ -z "$OVERLAP" ] && [ -n "$EP_IPS" ] && [ "$EP_COUNT" -ge 1 ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (endpoints must include only blue pods; endpoint IPs='${EP_IPS//$'\n'/,}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
