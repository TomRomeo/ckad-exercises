# Exercise 07: Deployment Basics

**Difficulty:** Easy
**Domain:** Application Deployment
**Namespace:** `ckad-deploy-basics`

## Context

The development team has requested a new web application be deployed to the cluster. The application must run multiple identical instances for high availability behind a load balancer. The team has standardized on `nginx:1.25` as the web server image and relies on consistent pod labeling for service discovery across the platform.

## Setup

```bash
./setup.sh
```

## Tasks

1. Deploy a web application named `webapp` in namespace `ckad-deploy-basics` using the `nginx:1.25` image
2. The application needs 3 identical instances running at all times for high availability
3. All pods must be discoverable via the label `app=webapp` so that other services can route traffic to them
4. The container should be named `nginx` and must accept HTTP traffic on port 80

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

You can generate a Deployment manifest quickly with:
```bash
kubectl create deployment webapp --image=nginx:1.25 --replicas=3 --dry-run=client -o yaml -n ckad-deploy-basics
```
Then edit it to ensure the container name is `nginx` and port 80 is exposed.
</details>

<details>
<summary>Hint 2</summary>

The key fields in a Deployment spec are:
- `spec.replicas`
- `spec.selector.matchLabels`
- `spec.template.metadata.labels`
- `spec.template.spec.containers[].name`
- `spec.template.spec.containers[].image`
- `spec.template.spec.containers[].ports[].containerPort`
</details>

<details>
<summary>Hint 3</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: ckad-deploy-basics
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```
</details>
