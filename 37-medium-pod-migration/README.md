# Exercise 37: Find a Pod by Label and Move It

**Difficulty:** Medium
**Domain:** Application Design and Build
**Namespace:** `ckad-staging` (source) → `ckad-shop` (target)

## Context

A Pod in namespace `ckad-staging` belongs to the e-commerce system `web-shop`, which is owned by the online-shop team. It ended up in the wrong namespace. The Pod's name is unknown — you have to find it by its labels — and it must be moved to the online-shop team's namespace `ckad-shop`. Recreating the Pod there is perfectly fine.

## Setup

```bash
./setup.sh
```

This creates namespaces `ckad-staging` and `ckad-shop`. The source namespace contains several pods; exactly one carries the label `system=web-shop`.

## Tasks

1. Find the Pod in `ckad-staging` that has the label `system=web-shop` (the name is not known in advance).
2. Move it to namespace `ckad-shop` using the same image. Recreating it there is fine.
3. The moved Pod must still carry the label `system=web-shop`, and the original must no longer exist in `ckad-staging`.

## Hints

<details>
<summary>Hint 1</summary>

Locate it with a label selector:
```
kubectl get pods -n ckad-staging -l system=web-shop
```
</details>

<details>
<summary>Hint 2</summary>

Export the pod definition, then clean it up (remove `namespace`, `status`, `resourceVersion`, `uid`, `creationTimestamp`):
```
kubectl get pod <name> -n ckad-staging -o yaml > /tmp/happy.yaml
```
Or simply recreate it with `kubectl run` using the same image and the `system=web-shop` label.
</details>

<details>
<summary>Hint 3</summary>

Apply/create it in the new namespace, verify it is Running, then delete the original:
```
kubectl delete pod <name> -n ckad-staging
```
</details>

## Verify

```bash
./verify.sh
```
