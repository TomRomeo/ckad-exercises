#!/bin/bash
set -euo pipefail

NAMESPACE="ckad-adv-pod"
PASS=0
FAIL=0
TOTAL=9

echo "=== Verifying Exercise 06: Advanced Pod Design ==="
echo ""

# Check 1: Pod exists with 1 main container and 2 initContainers (config-init + logger sidecar)
echo -n "Check 1/$TOTAL - Pod 'advanced-pod' has 1 main container and 2 initContainers: "
CONTAINER_COUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w | tr -d ' ') || CONTAINER_COUNT="0"
INIT_COUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[*].name}' 2>/dev/null | wc -w | tr -d ' ') || INIT_COUNT="0"
if [ "$CONTAINER_COUNT" = "1" ] && [ "$INIT_COUNT" = "2" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (containers: $CONTAINER_COUNT expected 1, initContainers: $INIT_COUNT expected 2)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Container names and images correct
echo -n "Check 2/$TOTAL - Images: app=nginx:1.25, logger=busybox:1.36, config-init=busybox:1.36: "
APP_IMG=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].image}' 2>/dev/null) || APP_IMG=""
LOGGER_IMG=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="logger")].image}' 2>/dev/null) || LOGGER_IMG=""
INIT_IMG=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="config-init")].image}' 2>/dev/null) || INIT_IMG=""
if [ "$APP_IMG" = "nginx:1.25" ] && [ "$LOGGER_IMG" = "busybox:1.36" ] && [ "$INIT_IMG" = "busybox:1.36" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (app='${APP_IMG:-}', logger='${LOGGER_IMG:-}', config-init='${INIT_IMG:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 3: logger is a native sidecar (restartPolicy: Always)
echo -n "Check 3/$TOTAL - Logger has restartPolicy=Always (native sidecar): "
LOGGER_RESTART=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="logger")].restartPolicy}' 2>/dev/null) || LOGGER_RESTART=""
if [ "$LOGGER_RESTART" = "Always" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (restartPolicy: '${LOGGER_RESTART:-not set}')"
  FAIL=$((FAIL + 1))
fi

# Check 4: log-volume is emptyDir, mounted in app and logger at /var/log/app
echo -n "Check 4/$TOTAL - Volume 'log-volume' (emptyDir) mounted at /var/log/app in app and logger: "
LOG_VOL=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="log-volume")].emptyDir}' 2>/dev/null) || LOG_VOL=""
APP_LOG_MOUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="log-volume")].mountPath}' 2>/dev/null) || APP_LOG_MOUNT=""
LOGGER_LOG_MOUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="logger")].volumeMounts[?(@.name=="log-volume")].mountPath}' 2>/dev/null) || LOGGER_LOG_MOUNT=""
if [ -n "$LOG_VOL" ] && [ "$APP_LOG_MOUNT" = "/var/log/app" ] && [ "$LOGGER_LOG_MOUNT" = "/var/log/app" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (emptyDir='${LOG_VOL:-missing}', app mount='${APP_LOG_MOUNT:-}', logger mount='${LOGGER_LOG_MOUNT:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 5: config-volume from ConfigMap mounted in config-init at /config
echo -n "Check 5/$TOTAL - Volume 'config-volume' from ConfigMap 'app-config' mounted at /config in config-init: "
CFG_CM=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="config-volume")].configMap.name}' 2>/dev/null) || CFG_CM=""
INIT_CFG_MOUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="config-init")].volumeMounts[?(@.name=="config-volume")].mountPath}' 2>/dev/null) || INIT_CFG_MOUNT=""
if [ "$CFG_CM" = "app-config" ] && [ "$INIT_CFG_MOUNT" = "/config" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (configMap='${CFG_CM:-}', init mount='${INIT_CFG_MOUNT:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 6: app-config-volume (emptyDir) mounted in config-init at /app-config and app at /app-config
echo -n "Check 6/$TOTAL - Volume 'app-config-volume' (emptyDir) mounted in config-init and app at /app-config: "
APPCFG_VOL=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="app-config-volume")].emptyDir}' 2>/dev/null) || APPCFG_VOL=""
INIT_APPCFG_MOUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.initContainers[?(@.name=="config-init")].volumeMounts[?(@.name=="app-config-volume")].mountPath}' 2>/dev/null) || INIT_APPCFG_MOUNT=""
APP_APPCFG_MOUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="app-config-volume")].mountPath}' 2>/dev/null) || APP_APPCFG_MOUNT=""
if [ -n "$APPCFG_VOL" ] && [ "$INIT_APPCFG_MOUNT" = "/app-config" ] && [ "$APP_APPCFG_MOUNT" = "/app-config" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (emptyDir='${APPCFG_VOL:-missing}', init mount='${INIT_APPCFG_MOUNT:-}', app mount='${APP_APPCFG_MOUNT:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 7: secret-volume from Secret mounted in app at /secrets
echo -n "Check 7/$TOTAL - Volume 'secret-volume' from Secret 'app-secret' mounted at /secrets in app: "
SEC_NAME=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.volumes[?(@.name=="secret-volume")].secret.secretName}' 2>/dev/null) || SEC_NAME=""
APP_SEC_MOUNT=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="secret-volume")].mountPath}' 2>/dev/null) || APP_SEC_MOUNT=""
if [ "$SEC_NAME" = "app-secret" ] && [ "$APP_SEC_MOUNT" = "/secrets" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (secret='${SEC_NAME:-}', mount='${APP_SEC_MOUNT:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 8: Resource requests on app container
echo -n "Check 8/$TOTAL - Resource requests (cpu=100m, memory=128Mi) on app: "
REQ_CPU=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.requests.cpu}' 2>/dev/null) || REQ_CPU=""
REQ_MEM=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.requests.memory}' 2>/dev/null) || REQ_MEM=""
if [ "$REQ_CPU" = "100m" ] && [ "$REQ_MEM" = "128Mi" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (cpu='${REQ_CPU:-}', memory='${REQ_MEM:-}')"
  FAIL=$((FAIL + 1))
fi

# Check 9: Resource limits on app container
echo -n "Check 9/$TOTAL - Resource limits (cpu=200m, memory=256Mi) on app: "
LIM_CPU=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.limits.cpu}' 2>/dev/null) || LIM_CPU=""
LIM_MEM=$(kubectl get pod advanced-pod -n "$NAMESPACE" -o jsonpath='{.spec.containers[?(@.name=="app")].resources.limits.memory}' 2>/dev/null) || LIM_MEM=""
if [ "$LIM_CPU" = "200m" ] && [ "$LIM_MEM" = "256Mi" ]; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL (cpu='${LIM_CPU:-}', memory='${LIM_MEM:-}')"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed out of $TOTAL"
exit "$FAIL"
