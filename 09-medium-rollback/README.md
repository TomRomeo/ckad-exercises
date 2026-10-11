# Exercise 09: Rollback a Deployment

**Difficulty:** Medium
**Domain:** Application Deployment
**Namespace:** `ckad-rollback`

## Context

A colleague accidentally deployed a broken image to the `rollback-app` Deployment in production. Pods are failing to start and users are reporting errors. The deployment has gone through several revisions, and the application was last known to be stable when running `nginx:1.24`. You need to restore service as quickly as possible.

## Setup

```bash
./setup.sh
```

This creates a Deployment `rollback-app` and applies two updates:
- Revision 1: `nginx:1.23` (initial)
- Revision 2: `nginx:1.24` (working)
- Revision 3: `nginx:1.25-nonexistent` (broken, image pull error)

## Tasks

1. Investigate the current state of the `rollback-app` Deployment and confirm that pods are failing
2. Review the rollout history to identify which revision was running the last known stable version (`nginx:1.24`)
3. Restore the deployment to that stable revision
4. Verify the rollout completes successfully and all 3 replicas are healthy

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

Check the rollout history:
```bash
kubectl rollout history deployment/rollback-app -n ckad-rollback
```
</details>

<details>
<summary>Hint 2</summary>

Inspect a specific revision to see which image it used:
```bash
kubectl rollout history deployment/rollback-app -n ckad-rollback --revision=2
```
</details>

<details>
<summary>Hint 3</summary>

Roll back to a specific revision:
```bash
kubectl rollout undo deployment/rollback-app -n ckad-rollback --to-revision=2
```

Or simply undo to the previous revision:
```bash
kubectl rollout undo deployment/rollback-app -n ckad-rollback
```
Note: `undo` without `--to-revision` goes to the immediately previous revision, which might not always be what you want.
</details>
