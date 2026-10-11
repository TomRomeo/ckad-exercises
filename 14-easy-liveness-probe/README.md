# Exercise 14: Liveness Probe

**Difficulty:** Easy
**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-liveness`

## Context

Your team is deploying a new web server and wants to ensure high availability. If the web server process hangs or becomes unresponsive, Kubernetes should automatically restart the container rather than leaving it in a broken state serving no traffic.

## Setup

Run the setup script to create the namespace:

```bash
./setup.sh
```

## Tasks

1. Deploy a pod named `liveness-pod` in the `ckad-liveness` namespace using image `nginx:1.25` with the container named `web`.
2. The pod must be automatically restarted if the web server stops responding. Configure a health check that verifies the server is responding to HTTP requests on its root path (port `80`).
3. The application takes approximately 5 seconds to initialize, and health should be verified every 10 seconds after that.

## Hints

<details>
<summary>Hint 1</summary>
The liveness probe is configured under `spec.containers[].livenessProbe` in the pod spec.
</details>

<details>
<summary>Hint 2</summary>

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 10
```
</details>

<details>
<summary>Hint 3</summary>
You can generate a base YAML with `kubectl run liveness-pod --image=nginx:1.25 --dry-run=client -o yaml > pod.yaml` and then edit it to add the probe and set the container name.
</details>

## Verify

```bash
./verify.sh
```
