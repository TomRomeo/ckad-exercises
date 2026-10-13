# Exercise 34: Fix a Deprecated HorizontalPodAutoscaler

**Difficulty:** Medium
**Domain:** Application Deployment
**Namespace:** `ckad-hpa`

## Context

A HorizontalPodAutoscaler manifest was written against an old Kubernetes release and no longer applies on this cluster, because its `apiVersion` has been removed from the API server. The platform team wants it updated and extended to scale on memory as well as CPU before it goes live for the `api-app` Deployment.

## Setup

```bash
./setup.sh
```

This creates the Deployment `api-app` in the `ckad-hpa` namespace and writes a broken HPA manifest to `/tmp/ckad-hpa/hpa.yaml`.

## Tasks

Edit `/tmp/ckad-hpa/hpa.yaml` so that it:

1. Uses a current, non-deprecated `apiVersion` (the `autoscaling/v2beta1`/`v2beta2` versions have been removed).
2. Sets `minReplicas` to `2` and `maxReplicas` to `5`.
3. Scales on **memory** utilization with a target average of `80`%, in addition to the existing CPU metric.

Then apply it. The HPA must target the existing `api-app` Deployment and be named `api-app`.

## Hints

<details>
<summary>Hint 1</summary>

The current stable version is `autoscaling/v2`. Check what the API server serves with:
```
kubectl api-resources | grep horizontalpodautoscaler
```
</details>

<details>
<summary>Hint 2</summary>

In `autoscaling/v2`, metrics live under `spec.metrics` as a list. A resource metric looks like:
```yaml
- type: Resource
  resource:
    name: memory
    target:
      type: Utilization
      averageUtilization: 80
```
Add this alongside the existing `cpu` entry.
</details>

<details>
<summary>Hint 3</summary>

Apply with `kubectl apply -f /tmp/ckad-hpa/hpa.yaml -n ckad-hpa` and inspect with `kubectl get hpa api-app -n ckad-hpa -o yaml`. The HPA object is valid even if metrics show `<unknown>` without a metrics-server.
</details>

## Verify

```bash
./verify.sh
```
