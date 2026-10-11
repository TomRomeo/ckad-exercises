# Exercise 15: Readiness Probe

**Difficulty:** Medium
**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-readiness`

## Context

A Deployment named `ready-app` runs 3 replicas behind the Service `ready-svc` in the `ckad-readiness` namespace. The containers accept traffic the moment they start, even before the application can actually serve requests. During a rollout the Service then briefly sends traffic to pods that are not ready yet, and some requests fail. The team wants the Service to route traffic only to pods that have confirmed they can serve.

## Setup

Run the setup script to create the namespace and deploy the resources:

```bash
./setup.sh
```

This creates the Deployment `ready-app` (3 replicas of `nginx:1.25`, container `nginx`, port 80) with no readiness probe, and the Service `ready-svc` selecting `app=ready-app`.

## Tasks

1. Add a readiness probe to the `ready-app` Deployment's container.
2. The probe must perform an HTTP GET on path `/` at port `80`.
3. Configure the timing so the probe waits `3` seconds before the first check, runs every `5` seconds, and marks the container not ready after `3` consecutive failures.
4. After your change, all 3 pods should become Ready and the Service `ready-svc` should list 3 endpoints.

## Hints

<details>
<summary>Hint 1</summary>
The readiness probe is configured under `spec.template.spec.containers[].readinessProbe`. Edit the Deployment in place with `kubectl edit deployment ready-app -n ckad-readiness`.
</details>

<details>
<summary>Hint 2</summary>

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 3
  periodSeconds: 5
  failureThreshold: 3
```
</details>

<details>
<summary>Hint 3</summary>
A readiness probe controls whether a pod receives Service traffic (unlike a liveness probe, which restarts the container). Check the result with `kubectl get pods -n ckad-readiness` and `kubectl get endpoints ready-svc -n ckad-readiness`.
</details>

## Verify

```bash
./verify.sh
```
