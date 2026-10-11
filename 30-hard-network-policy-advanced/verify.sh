#!/bin/bash
set -euo pipefail

NS="ckad-netpol-adv"
PASS=0
FAIL=0
TOTAL=10

echo "=== Verifying Exercise 30: Advanced Network Policies ==="
echo ""

# ---- backend-policy checks ----

# Check 1: backend-policy exists
echo -n "Check 1/10  - NetworkPolicy 'backend-policy' exists: "
if kubectl get networkpolicy backend-policy -n "$NS" 2>/dev/null >&2; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - NetworkPolicy 'backend-policy' not found"
  FAIL=$((FAIL + 1))
fi

# Check 2: backend-policy podSelector targets tier=api
echo -n "Check 2/10  - backend-policy targets tier=api: "
BP_SELECTOR=$(kubectl get networkpolicy backend-policy -n "$NS" -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null || echo "")
if [ "$BP_SELECTOR" = "api" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected podSelector tier=api, got tier='$BP_SELECTOR'"
  FAIL=$((FAIL + 1))
fi

# Check 3: backend-policy has ingress from web tier AND external namespace on port 8080
echo -n "Check 3/10  - backend-policy ingress: from web tier + external ns, port 8080: "
BP_JSON=$(kubectl get networkpolicy backend-policy -n "$NS" -o json 2>/dev/null || echo "{}")
BP_CHECK=$(echo "$BP_JSON" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    ingress = data.get('spec',{}).get('ingress',[])
    if not ingress:
        print('NO_INGRESS')
        sys.exit()
    rule = ingress[0]
    # Check port
    ports = rule.get('ports',[])
    has_port_8080 = any(p.get('port') == 8080 for p in ports)
    # Check from sources
    froms = rule.get('from',[])
    has_web_tier = False
    has_ext_ns = False
    for f in froms:
        ps = f.get('podSelector',{}).get('matchLabels',{})
        if ps.get('tier') == 'web':
            has_web_tier = True
        ns = f.get('namespaceSelector',{}).get('matchLabels',{})
        if ns.get('kubernetes.io/metadata.name') == 'ckad-netpol-external':
            has_ext_ns = True
    if has_port_8080 and has_web_tier and has_ext_ns:
        print('OK')
    else:
        parts = []
        if not has_port_8080: parts.append('missing port 8080')
        if not has_web_tier: parts.append('missing from tier=web')
        if not has_ext_ns: parts.append('missing from ns kubernetes.io/metadata.name=ckad-netpol-external')
        print('FAIL:' + ', '.join(parts))
except Exception as e:
    print(f'ERROR:{e}')
" 2>/dev/null || echo "ERROR")

if [ "$BP_CHECK" = "OK" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - $BP_CHECK"
  FAIL=$((FAIL + 1))
fi

# Check 4: backend-policy policyTypes includes Ingress
echo -n "Check 4/10  - backend-policy policyTypes includes Ingress: "
BP_PTYPES=$(kubectl get networkpolicy backend-policy -n "$NS" -o jsonpath='{.spec.policyTypes}' 2>/dev/null || echo "")
if echo "$BP_PTYPES" | grep -q "Ingress"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - policyTypes: '$BP_PTYPES'"
  FAIL=$((FAIL + 1))
fi

# ---- database-policy checks ----

# Check 5: database-policy exists with correct podSelector
echo -n "Check 5/10  - NetworkPolicy 'database-policy' exists, targets tier=data: "
DP_SELECTOR=$(kubectl get networkpolicy database-policy -n "$NS" -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null || echo "")
if [ "$DP_SELECTOR" = "data" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected podSelector tier=data, got tier='$DP_SELECTOR'"
  FAIL=$((FAIL + 1))
fi

# Check 6: database-policy ingress from api tier on port 5432
echo -n "Check 6/10  - database-policy ingress: from api tier, port 5432: "
DP_JSON=$(kubectl get networkpolicy database-policy -n "$NS" -o json 2>/dev/null || echo "{}")
DP_INGRESS_CHECK=$(echo "$DP_JSON" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    ingress = data.get('spec',{}).get('ingress',[])
    if not ingress:
        print('NO_INGRESS')
        sys.exit()
    rule = ingress[0]
    ports = rule.get('ports',[])
    has_port = any(p.get('port') == 5432 for p in ports)
    froms = rule.get('from',[])
    has_api = any(f.get('podSelector',{}).get('matchLabels',{}).get('tier') == 'api' for f in froms)
    if has_port and has_api:
        print('OK')
    else:
        parts = []
        if not has_port: parts.append('missing port 5432')
        if not has_api: parts.append('missing from tier=api')
        print('FAIL:' + ', '.join(parts))
except Exception as e:
    print(f'ERROR:{e}')
" 2>/dev/null || echo "ERROR")

if [ "$DP_INGRESS_CHECK" = "OK" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - $DP_INGRESS_CHECK"
  FAIL=$((FAIL + 1))
fi

# Check 7: database-policy egress allows DNS (port 53 UDP) only
echo -n "Check 7/10  - database-policy egress: DNS only (port 53 UDP): "
DP_EGRESS_CHECK=$(echo "$DP_JSON" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    egress = data.get('spec',{}).get('egress',[])
    if not egress:
        print('NO_EGRESS')
        sys.exit()
    # Check that there's a rule allowing port 53 UDP
    has_dns = False
    for rule in egress:
        ports = rule.get('ports',[])
        for p in ports:
            if p.get('port') == 53 and p.get('protocol','TCP') == 'UDP':
                has_dns = True
    if has_dns:
        print('OK')
    else:
        print('FAIL:no egress rule for port 53 UDP')
except Exception as e:
    print(f'ERROR:{e}')
" 2>/dev/null || echo "ERROR")

if [ "$DP_EGRESS_CHECK" = "OK" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - $DP_EGRESS_CHECK"
  FAIL=$((FAIL + 1))
fi

# Check 8: database-policy policyTypes includes both Ingress and Egress
echo -n "Check 8/10  - database-policy policyTypes includes Ingress and Egress: "
DP_PTYPES=$(kubectl get networkpolicy database-policy -n "$NS" -o jsonpath='{.spec.policyTypes}' 2>/dev/null || echo "")
if echo "$DP_PTYPES" | grep -q "Ingress" && echo "$DP_PTYPES" | grep -q "Egress"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL - policyTypes: '$DP_PTYPES' (need both Ingress and Egress)"
  FAIL=$((FAIL + 1))
fi

# ---- default-deny-ingress checks ----

# Check 9: default-deny-ingress exists with empty podSelector
echo -n "Check 9/10  - NetworkPolicy 'default-deny-ingress' exists, empty podSelector: "
DDI_JSON=$(kubectl get networkpolicy default-deny-ingress -n "$NS" -o json 2>/dev/null || echo "")
if [ -z "$DDI_JSON" ]; then
  echo "FAIL - NetworkPolicy 'default-deny-ingress' not found"
  FAIL=$((FAIL + 1))
else
  DDI_SELECTOR=$(echo "$DDI_JSON" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    sel = data.get('spec',{}).get('podSelector',{})
    ml = sel.get('matchLabels', None)
    me = sel.get('matchExpressions', None)
    if (ml is None or ml == {}) and (me is None or me == []):
        print('OK')
    else:
        print('FAIL:podSelector is not empty')
except Exception as e:
    print(f'ERROR:{e}')
" 2>/dev/null || echo "ERROR")
  if [ "$DDI_SELECTOR" = "OK" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL - $DDI_SELECTOR"
    FAIL=$((FAIL + 1))
  fi
fi

# Check 10: At least 3 NetworkPolicies exist
echo -n "Check 10/10 - At least 3 NetworkPolicies in namespace: "
NP_COUNT=$(kubectl get networkpolicy -n "$NS" --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$NP_COUNT" -ge 3 ] 2>/dev/null; then
  echo "PASS ($NP_COUNT found)"
  PASS=$((PASS + 1))
else
  echo "FAIL - Expected at least 3, found $NP_COUNT"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
