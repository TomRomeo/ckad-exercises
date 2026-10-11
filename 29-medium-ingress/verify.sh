#!/bin/bash
set -euo pipefail

NS="ckad-ingress"
PASS=0
FAIL=0
TOTAL=5

echo "=== Verifying Exercise 29: Ingress Resource ==="
echo ""

# Check 1: Ingress exists
echo -n "Check 1/$TOTAL - Ingress 'app-ingress' exists: "
if kubectl get ingress app-ingress -n "$NS" >/dev/null 2>&1; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Ingress 'app-ingress' not found in namespace '$NS'"
  FAIL=$((FAIL + 1))
fi

# Check 2: Has host myapp.example.com
echo -n "Check 2/$TOTAL - Host is 'myapp.example.com': "
HOST=$(kubectl get ingress app-ingress -n "$NS" -o jsonpath='{.spec.rules[0].host}' 2>/dev/null || echo "")
if [ "$HOST" = "myapp.example.com" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected host 'myapp.example.com', got '$HOST'"
  FAIL=$((FAIL + 1))
fi

# Check 3: Path /web routes to web-svc port 80
echo -n "Check 3/$TOTAL - Path /web routes to web-svc:80: "
INGRESS_JSON=$(kubectl get ingress app-ingress -n "$NS" -o json 2>/dev/null || echo "{}")
PATHS=$(echo "$INGRESS_JSON" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    paths = data.get('spec',{}).get('rules',[{}])[0].get('http',{}).get('paths',[])
    for p in paths:
        path = p.get('path','')
        svc_name = p.get('backend',{}).get('service',{}).get('name','')
        svc_port = p.get('backend',{}).get('service',{}).get('port',{}).get('number','')
        print(f'{path}:{svc_name}:{svc_port}')
except:
    pass
" 2>/dev/null || echo "")

if echo "$PATHS" | grep -q "^/web:web-svc:80$"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Path /web -> web-svc:80 not found"
  FAIL=$((FAIL + 1))
fi

# Check 4: Path /api routes to api-svc port 80
echo -n "Check 4/$TOTAL - Path /api routes to api-svc:80: "
if echo "$PATHS" | grep -q "^/api:api-svc:80$"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Path /api -> api-svc:80 not found"
  FAIL=$((FAIL + 1))
fi

# Check 5: ingressClassName is nginx
echo -n "Check 5/$TOTAL - ingressClassName is 'nginx': "
INGRESS_CLASS=$(kubectl get ingress app-ingress -n "$NS" -o jsonpath='{.spec.ingressClassName}' 2>/dev/null || echo "")
if [ "$INGRESS_CLASS" = "nginx" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected ingressClassName 'nginx', got '$INGRESS_CLASS'"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
