#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-rbac"
PASS=0
FAIL=0
TOTAL=8

echo "=== Verifying Exercise 25: RBAC - Roles and RoleBindings ==="
echo ""

# Check 1: Role pod-reader exists with correct rules
echo -n "1. Role 'pod-reader' exists with correct rules: "
VERBS=$(kubectl get role pod-reader -n "$NAMESPACE" -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null || true)
RESOURCES=$(kubectl get role pod-reader -n "$NAMESPACE" -o jsonpath='{.rules[0].resources[*]}' 2>/dev/null || true)
API_GROUPS=$(kubectl get role pod-reader -n "$NAMESPACE" -o jsonpath='{.rules[0].apiGroups[*]}' 2>/dev/null || true)
VERBS_OK=false
RESOURCES_OK=false
API_OK=false
if echo "$VERBS" | grep -q "get" && echo "$VERBS" | grep -q "list" && echo "$VERBS" | grep -q "watch"; then
  VERBS_OK=true
fi
if echo "$RESOURCES" | grep -q "pods" && echo "$RESOURCES" | grep -q "pods/log"; then
  RESOURCES_OK=true
fi
# Empty string is the core API group
if [[ -z "$API_GROUPS" ]] || [[ "$API_GROUPS" == "" ]]; then
  API_OK=true
fi
if $VERBS_OK && $RESOURCES_OK && $API_OK; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (verbs: '$VERBS', resources: '$RESOURCES', apiGroups: '$API_GROUPS')"
  FAIL=$((FAIL + 1))
fi

# Check 2: RoleBinding dev-user-pod-reader exists and binds correctly
echo -n "2. RoleBinding 'dev-user-pod-reader' exists and binds correctly: "
ROLE_REF=$(kubectl get rolebinding dev-user-pod-reader -n "$NAMESPACE" -o jsonpath='{.roleRef.name}' 2>/dev/null || true)
SUBJECT_NAME=$(kubectl get rolebinding dev-user-pod-reader -n "$NAMESPACE" -o jsonpath='{.subjects[0].name}' 2>/dev/null || true)
SUBJECT_KIND=$(kubectl get rolebinding dev-user-pod-reader -n "$NAMESPACE" -o jsonpath='{.subjects[0].kind}' 2>/dev/null || true)
if [[ "$ROLE_REF" == "pod-reader" ]] && [[ "$SUBJECT_NAME" == "dev-user" ]] && [[ "$SUBJECT_KIND" == "ServiceAccount" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (roleRef: '$ROLE_REF', subject: '$SUBJECT_KIND/$SUBJECT_NAME')"
  FAIL=$((FAIL + 1))
fi

# Check 3: Role deploy-manager exists with correct rules
echo -n "3. Role 'deploy-manager' exists with correct rules: "
VERBS=$(kubectl get role deploy-manager -n "$NAMESPACE" -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null || true)
RESOURCES=$(kubectl get role deploy-manager -n "$NAMESPACE" -o jsonpath='{.rules[0].resources[*]}' 2>/dev/null || true)
API_GROUPS=$(kubectl get role deploy-manager -n "$NAMESPACE" -o jsonpath='{.rules[0].apiGroups[*]}' 2>/dev/null || true)
VERBS_OK=false
RESOURCES_OK=false
API_OK=false
if echo "$VERBS" | grep -q "get" && echo "$VERBS" | grep -q "list" && echo "$VERBS" | grep -q "create" && echo "$VERBS" | grep -q "update" && echo "$VERBS" | grep -q "delete"; then
  VERBS_OK=true
fi
if echo "$RESOURCES" | grep -q "deployments"; then
  RESOURCES_OK=true
fi
if [[ "$API_GROUPS" == "apps" ]]; then
  API_OK=true
fi
if $VERBS_OK && $RESOURCES_OK && $API_OK; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (verbs: '$VERBS', resources: '$RESOURCES', apiGroups: '$API_GROUPS')"
  FAIL=$((FAIL + 1))
fi

# Check 4: RoleBinding dev-user-deploy-manager exists and binds correctly
echo -n "4. RoleBinding 'dev-user-deploy-manager' exists and binds correctly: "
ROLE_REF=$(kubectl get rolebinding dev-user-deploy-manager -n "$NAMESPACE" -o jsonpath='{.roleRef.name}' 2>/dev/null || true)
SUBJECT_NAME=$(kubectl get rolebinding dev-user-deploy-manager -n "$NAMESPACE" -o jsonpath='{.subjects[0].name}' 2>/dev/null || true)
SUBJECT_KIND=$(kubectl get rolebinding dev-user-deploy-manager -n "$NAMESPACE" -o jsonpath='{.subjects[0].kind}' 2>/dev/null || true)
if [[ "$ROLE_REF" == "deploy-manager" ]] && [[ "$SUBJECT_NAME" == "dev-user" ]] && [[ "$SUBJECT_KIND" == "ServiceAccount" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (roleRef: '$ROLE_REF', subject: '$SUBJECT_KIND/$SUBJECT_NAME')"
  FAIL=$((FAIL + 1))
fi

# Check 5: dev-user can get pods
echo -n "5. dev-user can get pods: "
RESULT=$(kubectl auth can-i get pods --as=system:serviceaccount:ckad-rbac:dev-user -n "$NAMESPACE" 2>/dev/null || true)
if [[ "$RESULT" == "yes" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$RESULT')"
  FAIL=$((FAIL + 1))
fi

# Check 6: dev-user can list deployments
echo -n "6. dev-user can list deployments: "
RESULT=$(kubectl auth can-i list deployments --as=system:serviceaccount:ckad-rbac:dev-user -n "$NAMESPACE" 2>/dev/null || true)
if [[ "$RESULT" == "yes" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$RESULT')"
  FAIL=$((FAIL + 1))
fi

# Check 7: dev-user cannot delete pods
echo -n "7. dev-user cannot delete pods: "
RESULT=$(kubectl auth can-i delete pods --as=system:serviceaccount:ckad-rbac:dev-user -n "$NAMESPACE" 2>/dev/null || true)
if [[ "$RESULT" == "no" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$RESULT')"
  FAIL=$((FAIL + 1))
fi

# Check 8: dev-user cannot create services
echo -n "8. dev-user cannot create services: "
RESULT=$(kubectl auth can-i create services --as=system:serviceaccount:ckad-rbac:dev-user -n "$NAMESPACE" 2>/dev/null || true)
if [[ "$RESULT" == "no" ]]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (got: '$RESULT')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit $FAIL
