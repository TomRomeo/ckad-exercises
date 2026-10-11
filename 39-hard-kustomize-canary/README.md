# Exercise 39: Canary Rollout with Kustomize

**Difficulty:** Hard
**Domain:** Application Deployment
**Namespace:** `ckad-kustomize`

## Context

Namespace `ckad-kustomize` hosts a canary deployment managed via **Kustomize**. The app runs as two Deployments behind one Service: `web-main` (the stable track) and `web-canary` (the new track). Traffic split is approximated by the ratio of running pods across the two Deployments. The team wants to re-balance the rollout by editing the Kustomize configuration and applying it so the live cluster state matches.

The Kustomize directory is written to `/tmp/ckad-kustomize/` during setup.

## Setup

```bash
./setup.sh
```

This creates the namespace `ckad-kustomize` and writes a Kustomize base to `/tmp/ckad-kustomize/` containing `web-main` and `web-canary` Deployments and a Service. Nothing is applied yet.

## Tasks

Edit the Kustomize configuration under `/tmp/ckad-kustomize/` and apply it so that the **total** number of pods (`web-main` + `web-canary`) is **10**, with **20%** of traffic going to the canary.

- Total pods: `10`
- Canary share: `20%`, so `web-canary` runs `2` pods and `web-main` runs `8` pods
- Change only the Deployment replica counts. Do **not** modify the Service
- Apply with `kubectl apply -k /tmp/ckad-kustomize/`

## Hints

<details>
<summary>Hint 1</summary>

Kustomize can override replica counts declaratively. In `kustomization.yaml`:
```yaml
replicas:
  - name: web-main
    count: 8
  - name: web-canary
    count: 2
```
</details>

<details>
<summary>Hint 2</summary>

Preview the rendered manifests before applying:
```
kubectl kustomize /tmp/ckad-kustomize/
```
</details>

<details>
<summary>Hint 3</summary>

Apply the whole directory with the `-k` flag:
```
kubectl apply -k /tmp/ckad-kustomize/
```
Then confirm with `kubectl get deploy -n ckad-kustomize`.
</details>

## Verify

```bash
./verify.sh
```
