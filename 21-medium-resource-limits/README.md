# Exercise 21: Resource Requests and Limits

**Difficulty:** Medium
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-resources`

## Context

The cluster administrator requires all pods to declare their resource needs for proper scheduling and to prevent resource starvation. You need to deploy two workloads with appropriate resource constraints based on their expected usage profiles.

## Tasks

1. Deploy a web server pod named `resource-pod` (image `nginx:1.25`, container name `web`) in namespace `ckad-resources`. This workload typically needs 100 millicores of CPU and 128Mi of memory under normal operation, but may burst up to 250 millicores of CPU and 256Mi of memory under peak load. Configure the pod so the scheduler can guarantee the baseline resources and enforce the upper bounds.

2. Deploy a background worker pod named `resource-pod-2` (image `busybox:1.36`, container name `worker`, command: `["sleep", "3600"]`) in namespace `ckad-resources`. This is a lighter workload that normally consumes 50 millicores of CPU and 64Mi of memory, capped at a maximum of 100 millicores of CPU and 128Mi of memory.

## Hints

<details>
<summary>Hint 1</summary>

Resource requests and limits go under `spec.containers[].resources`:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "250m"
    memory: "256Mi"
```
</details>

<details>
<summary>Hint 2</summary>

You can generate a pod YAML template with:
```bash
kubectl run resource-pod --image=nginx:1.25 --dry-run=client -o yaml > pod.yaml
```
Then edit the YAML to add resource requests/limits and change the container name.
</details>

<details>
<summary>Hint 3</summary>

CPU is measured in millicores (1000m = 1 core). Memory is measured in bytes (Mi = mebibytes).
</details>
