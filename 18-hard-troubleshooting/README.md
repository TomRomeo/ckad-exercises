# Exercise 18: Multi-Resource Troubleshooting

**Difficulty:** Hard
**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-troubleshoot`

## Context

A junior engineer deployed a web application stack to the `ckad-troubleshoot` namespace, but nothing is working correctly. The Deployment pods are crash-looping, the Service has no endpoints, and a debug pod still needs to be created to verify environment configuration. You have been asked to investigate and fix all the issues so the application is fully operational.

## Setup

Run the setup script to create the namespace and deploy the broken resources:

```bash
./setup.sh
```

The following resources are deployed (all with issues):
- **Deployment `web-deploy`**: pods are crashing
- **Service `web-svc`**: not routing traffic to the correct pods
- **ConfigMap `app-conf`**: contains database configuration

## Tasks

1. The `web-deploy` Deployment pods are crash-looping. The application should start with its default entrypoint. Investigate what is overriding it and fix the Deployment so pods run properly.
2. The Service `web-svc` is supposed to route traffic to the `web-deploy` pods, but has no endpoints. Investigate why the Service cannot discover the Deployment's pods and fix it.
3. A ConfigMap named `app-conf` exists with database connection details. Create a new pod named `debug-pod` (image `busybox:1.36`, command `sleep 3600`) that loads all values from this ConfigMap as environment variables. Verify the pod has the expected `DB_HOST` and `DB_PORT` variables.

## Hints

<details>
<summary>Hint 1</summary>
Check pod status and events: `kubectl describe pod -l app=web -n ckad-troubleshoot`. Look at the container command. Is it a valid nginx command?
</details>

<details>
<summary>Hint 2</summary>
To fix the Deployment, remove the `command` field from the container spec so nginx uses its default entrypoint:
`kubectl edit deployment web-deploy -n ckad-troubleshoot`
</details>

<details>
<summary>Hint 3</summary>
Check the Service selector: `kubectl get svc web-svc -n ckad-troubleshoot -o yaml`. Compare it with the pod labels: `kubectl get pods -n ckad-troubleshoot --show-labels`. Use `kubectl edit svc web-svc -n ckad-troubleshoot` to fix the selector.
</details>

<details>
<summary>Hint 4</summary>
To mount a ConfigMap as environment variables, use `envFrom` in the pod spec:

```yaml
envFrom:
  - configMapRef:
      name: app-conf
```
</details>

## Verify

```bash
./verify.sh
```
