# Exercise 24: ResourceQuota and LimitRange

**Difficulty:** Medium
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-quota`

## Context

The platform team needs to enforce resource boundaries on the `ckad-quota` namespace to prevent any single team from consuming too many cluster resources. They also want sensible defaults applied to workloads whose developers forget to specify resource constraints.

## Tasks

1. Create a quota named `compute-quota` in namespace `ckad-quota` that caps the namespace at: 1 CPU and 1Gi memory for total guaranteed resources, 2 CPU and 2Gi memory for total upper-bound resources, and a maximum of 5 pods.

2. Not all developers remember to set resource constraints on their containers. Create a policy named `default-limits` in namespace `ckad-quota` that automatically assigns baseline resource needs of 100m CPU / 128Mi memory and upper bounds of 200m CPU / 256Mi memory to any container that doesn't specify its own.

3. Deploy a pod named `quota-pod` (image `nginx:1.25`, container name `app`) in namespace `ckad-quota` with explicit resource needs of 150m CPU / 200Mi memory guaranteed, and upper bounds of 300m CPU / 400Mi memory.

## Hints

<details>
<summary>Hint 1</summary>

ResourceQuota YAML structure:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: ckad-quota
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "5"
```
</details>

<details>
<summary>Hint 2</summary>

LimitRange YAML structure:
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: ckad-quota
spec:
  limits:
  - default:
      cpu: 200m
      memory: 256Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
```
</details>

<details>
<summary>Hint 3</summary>

When a ResourceQuota with compute resources exists in a namespace, every pod must specify resource requests and limits. The LimitRange provides defaults for pods that don't specify them explicitly.
</details>

<details>
<summary>Hint 4</summary>

Check quota usage:
```bash
kubectl describe resourcequota compute-quota -n ckad-quota
```
</details>
