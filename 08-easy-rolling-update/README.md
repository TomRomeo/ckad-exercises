# Exercise 08: Rolling Update

**Difficulty:** Easy
**Domain:** Application Deployment
**Namespace:** `ckad-rolling-update`

## Context

The `web-app` Deployment is currently running `nginx:1.24` with 4 replicas in production. A new version of the image (`nginx:1.25`) has been tested and approved for release. The operations team requires zero-downtime upgrades for all production services. Every deployment change must also be traceable, so the team can see what changed and when in the rollout history.

## Setup

```bash
./setup.sh
```

This creates a Deployment named `web-app` with image `nginx:1.24` and 4 replicas.

## Tasks

1. Upgrade the `web-app` Deployment to use `nginx:1.25` without causing any downtime
2. Ensure the change is recorded in the deployment's rollout history so the team can audit what was changed
3. Wait for the rollout to finish successfully
4. Confirm that all 4 replicas are running the new version

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

You can update the image with:
```bash
kubectl set image deployment/web-app nginx=nginx:1.25 -n ckad-rolling-update
```
</details>

<details>
<summary>Hint 2</summary>

To record the change cause, annotate the deployment:
```bash
kubectl annotate deployment/web-app kubernetes.io/change-cause="Updated image to nginx:1.25" -n ckad-rolling-update
```
</details>

<details>
<summary>Hint 3</summary>

Wait for the rollout to complete:
```bash
kubectl rollout status deployment/web-app -n ckad-rolling-update
```

Check rollout history:
```bash
kubectl rollout history deployment/web-app -n ckad-rolling-update
```
</details>
