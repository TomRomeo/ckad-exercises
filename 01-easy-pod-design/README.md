# Exercise 01: Pod Design Basics

**Difficulty:** Easy
**Domain:** Application Design and Build
**Namespace:** `ckad-pod-design`

## Context

The frontend team has requested a new web server pod for their application. The pod needs to be properly labeled so that Kubernetes services can discover and route traffic to it. The team also requires an annotation for internal documentation purposes.

## Tasks

1. Deploy a pod named `web-pod` running the `nginx:1.25` image in the `ckad-pod-design` namespace.
2. The pod must be discoverable by the service mesh, which selects workloads based on an `app` label of `web` and a `tier` label of `frontend`.
3. For the team's internal documentation system, the pod must carry a description of `CKAD practice pod`.
4. The pod serves HTTP traffic on port **80**, so the container must declare this port.

## Hints

<details>
<summary>Hint 1</summary>

You can generate a pod YAML manifest using:
```
kubectl run web-pod --image=nginx:1.25 --port=80 --dry-run=client -o yaml
```
</details>

<details>
<summary>Hint 2</summary>

Labels can be added in the `metadata.labels` section or via `kubectl label`. Annotations go in `metadata.annotations`.
</details>

<details>
<summary>Hint 3</summary>

Container ports are defined under `spec.containers[].ports[]` with `containerPort: 80`.
</details>
