# Exercise 27: Create a NodePort Service

**Difficulty:** Easy
**Domain:** 5 - Services and Networking
**Namespace:** `ckad-svc-nodeport`

## Context

The `web-frontend` Deployment (2 replicas) is running in the `ckad-svc-nodeport` namespace and needs to be accessible from outside the cluster for development and testing purposes. Create a Service named `frontend-svc` that exposes the frontend pods (labeled `app=web-frontend`) on port 80, and makes them reachable on every cluster node at port 30080. Traffic arriving on the node port should be forwarded to port 80 on the pods.

## Setup

```bash
./setup.sh
```

## Tasks

1. Create a Service named `frontend-svc` in namespace `ckad-svc-nodeport` that makes the `web-frontend` pods reachable from outside the cluster.
2. The service must select pods labeled `app=web-frontend` and listen on port 80.
3. External clients should be able to reach the application at port 30080 on any cluster node's IP address, with traffic forwarded to port 80 on the pods.

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

You can start with an imperative command and then edit:
```bash
kubectl expose deployment web-frontend --name=frontend-svc --type=NodePort --port=80 --target-port=80 -n ckad-svc-nodeport --dry-run=client -o yaml > frontend-svc.yaml
```
Then edit the YAML to add the `nodePort: 30080` field.
</details>

<details>
<summary>Hint 2</summary>

The `nodePort` field goes inside the `ports` array in the Service spec:
```yaml
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```
</details>

<details>
<summary>Hint 3</summary>

NodePort range is 30000-32767 by default. Port 30080 is within this range.
</details>
