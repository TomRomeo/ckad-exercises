# Exercise 17: Startup Probe

**Difficulty:** Medium
**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-startup`

## Context

Your team is deploying an application that has a potentially slow initialization phase — it may take up to 60 seconds to become ready on cold starts (loading caches, running migrations, etc.). Without special handling, Kubernetes may kill the container before it finishes starting up, mistaking slow startup for a crash. The application also needs ongoing health monitoring once it is running.

## Setup

Run the setup script to create the namespace:

```bash
./setup.sh
```

## Tasks

1. Deploy a pod named `slow-start-pod` in the `ckad-startup` namespace using image `nginx:1.25` with the container named `app`.
2. Configure the pod with comprehensive health checking for all three lifecycle phases:
   - **Startup**: The application may take up to 60 seconds to become ready. Check the root path on port `80` every 2 seconds during startup, allowing enough consecutive failures to cover the full 60-second window.
   - **Liveness**: Once started, verify the application is still alive by checking the same HTTP endpoint every 10 seconds. If it becomes unresponsive, restart it.
   - **Readiness**: Check every 5 seconds whether the application is ready to accept traffic on its HTTP endpoint (root path, port `80`).

## Hints

<details>
<summary>Hint 1</summary>
All three probes are configured under `spec.containers[]` at the same level: `startupProbe`, `livenessProbe`, and `readinessProbe`.
</details>

<details>
<summary>Hint 2</summary>

```yaml
startupProbe:
  httpGet:
    path: /
    port: 80
  failureThreshold: 30
  periodSeconds: 2
livenessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 5
```
</details>

<details>
<summary>Hint 3</summary>
You can start with `kubectl run slow-start-pod --image=nginx:1.25 --dry-run=client -o yaml > pod.yaml`, edit the YAML to add all three probes and set the container name to `app`, then `kubectl apply -f pod.yaml -n ckad-startup`.
</details>

## Verify

```bash
./verify.sh
```
