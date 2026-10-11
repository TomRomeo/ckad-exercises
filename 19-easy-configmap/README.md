# Exercise 19: ConfigMap Basics

**Difficulty:** Easy
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-configmap`

## Context

The development team wants to externalize their application's configuration so that settings can be changed without rebuilding the container image. They have asked you to deploy the application with its configuration stored separately in the cluster.

## Tasks

1. Store the following application settings in a ConfigMap named `app-config` in namespace `ckad-configmap`:
   - The application environment is `production`
   - Debugging is disabled (`false`)
   - The application listens on port `8080`
   The keys must be named `APP_ENV`, `APP_DEBUG`, and `APP_PORT` respectively.

2. Deploy a pod named `config-pod` (image `nginx:1.25`, container name `app`) that loads all configuration values from the ConfigMap as environment variables. The environment variable names inside the container should match the ConfigMap keys exactly.

## Hints

<details>
<summary>Hint 1</summary>

You can create a ConfigMap imperatively:
```bash
kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_DEBUG=false --from-literal=APP_PORT=8080 -n ckad-configmap
```
</details>

<details>
<summary>Hint 2</summary>

To use `envFrom` in a pod spec:
```yaml
spec:
  containers:
  - name: app
    image: nginx:1.25
    envFrom:
    - configMapRef:
        name: app-config
```
</details>

<details>
<summary>Hint 3</summary>

Verify environment variables inside the pod:
```bash
kubectl exec config-pod -n ckad-configmap -- env | grep APP_
```
</details>
