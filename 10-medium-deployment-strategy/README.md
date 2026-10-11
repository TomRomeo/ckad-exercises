# Exercise 10: Deployment Strategy Configuration

**Difficulty:** Medium
**Domain:** Application Deployment
**Namespace:** `ckad-deploy-strategy`

## Context

You are deploying a critical web application that serves customer-facing traffic. The operations team has strict requirements for how rolling updates are performed to minimize risk and maintain service levels during deployments. They also need the ability to quickly roll back to recent versions if issues arise.

## Setup

```bash
./setup.sh
```

## Tasks

1. Create a Deployment named `strategy-app` in namespace `ckad-deploy-strategy` using image `nginx:1.25` with 5 replicas and the label `app=strategy-app`
2. Configure rolling updates so that at most 1 pod may be unavailable at any time during an update, ensuring the service stays healthy
3. Allow up to 2 additional pods to run temporarily above the desired count to accelerate the rollout
4. Each new pod must be stable for at least 10 seconds before it is considered available, preventing premature traffic routing to unstable instances
5. Retain the last 5 deployment revisions so the team can roll back if needed

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

Start by generating a base manifest:
```bash
kubectl create deployment strategy-app --image=nginx:1.25 --replicas=5 --dry-run=client -o yaml -n ckad-deploy-strategy > deployment.yaml
```
Then add the strategy, minReadySeconds, and revisionHistoryLimit fields.
</details>

<details>
<summary>Hint 2</summary>

The strategy section goes under `spec`:
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  minReadySeconds: 10
  revisionHistoryLimit: 5
```
</details>

<details>
<summary>Hint 3</summary>

Full manifest:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strategy-app
  namespace: ckad-deploy-strategy
spec:
  replicas: 5
  revisionHistoryLimit: 5
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  selector:
    matchLabels:
      app: strategy-app
  template:
    metadata:
      labels:
        app: strategy-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```
</details>
