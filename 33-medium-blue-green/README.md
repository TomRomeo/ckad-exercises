# Exercise 33: Blue-Green Deployment Cutover

**Difficulty:** Medium
**Domain:** Application Deployment
**Namespace:** `ckad-bluegreen`

## Context

In the `ckad-bluegreen` namespace, the web team runs two versions of a web app as Deployments `web-blue` and `web-green`. The Service `web-svc` currently load-balances across **both** versions. The team wants to ship a new image to the green version, but then — following a blue-green strategy — cut all live traffic back to the blue version in a single, instant switch.

## Setup

```bash
./setup.sh
```

This creates:
- Deployment `web-blue` — pods labelled `app=web, version=blue`
- Deployment `web-green` — pods labelled `app=web, version=green`, image `nginx:1.30-alpine`
- Service `web-svc` — selector `app=web` (matches both Deployments)

## Tasks

1. Update the image of Deployment `web-green` from `nginx:1.30-alpine` to `nginx:1.31-alpine`.
2. In blue-green fashion, update the Service `web-svc` so that it routes traffic **only** to the `web-blue` Deployment's pods (do not delete the green Deployment).

## Hints

<details>
<summary>Hint 1</summary>

Update the green image with:
```
kubectl set image deployment/web-green -n ckad-bluegreen <container>=nginx:1.31-alpine
```
Find the container name with `kubectl get deploy web-green -n ckad-bluegreen -o jsonpath='{.spec.template.spec.containers[*].name}'`.
</details>

<details>
<summary>Hint 2</summary>

The pods differ by their `version` label. To send traffic only to blue, the Service selector must match `version: blue` (in addition to `app: web`).
</details>

<details>
<summary>Hint 3</summary>

Edit the Service selector:
```
kubectl edit svc web-svc -n ckad-bluegreen
```
Then confirm the endpoints only point to blue pods: `kubectl get endpoints web-svc -n ckad-bluegreen`.
</details>

## Verify

```bash
./verify.sh
```
