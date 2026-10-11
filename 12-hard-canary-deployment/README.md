# Exercise 12: Canary Deployment

**Difficulty:** Hard
**Domain:** Application Deployment
**Namespace:** `ckad-canary`

## Context

The stable version of your application (`app-stable`, running `nginx:1.24` with 4 replicas) is serving production traffic through the `my-app-svc` Service. A new version (`nginx:1.25`) has passed integration testing, but before a full rollout, the team wants to validate it with real production traffic. You need to deploy a canary that receives approximately 20% of traffic alongside the stable version. The existing Service must not be modified — both deployments need to be routable through it.

## Setup

```bash
./setup.sh
```

This creates:
- A Deployment `app-stable` with image `nginx:1.24`, 4 replicas, labels `app=my-app, version=stable`
- A Service `my-app-svc` selecting on `app=my-app` (not version-specific)

## Tasks

1. Examine the existing Service `my-app-svc` to understand how it selects pods
2. Deploy a canary version of the application named `app-canary` in namespace `ckad-canary` using image `nginx:1.25`
3. The canary must receive traffic from the existing Service without any changes to the Service itself
4. Size the canary so that approximately 20% of total traffic is routed to the new version (there are currently 4 stable pods)
5. Label the canary pods with `version=canary` to distinguish them from stable pods

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

The key to canary deployments in Kubernetes is having both Deployments share a common label that the Service selects on. The Service uses `app=my-app` as its selector, so both the stable and canary pods must have this label.
</details>

<details>
<summary>Hint 2</summary>

The canary Deployment needs:
- `matchLabels` with at least `app=my-app` and `version=canary`
- Pod template labels: `app=my-app` and `version=canary`
- The Service selector `app=my-app` will match both stable and canary pods
</details>

<details>
<summary>Hint 3</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
  namespace: ckad-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
      version: canary
  template:
    metadata:
      labels:
        app: my-app
        version: canary
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```
</details>
