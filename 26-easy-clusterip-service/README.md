# Exercise 26: Create a ClusterIP Service

**Difficulty:** Easy
**Domain:** 5 - Services and Networking
**Namespace:** `ckad-svc-clusterip`

## Context

A `backend` Deployment with 2 replicas is running in the `ckad-svc-clusterip` namespace. Other applications within the cluster need to reach this backend via a stable internal DNS name. Create a Service named `backend-svc` that provides internal-only access to the backend pods (labeled `app=backend`) on port 80. The service should only be reachable from within the cluster.

## Setup

```bash
./setup.sh
```

## Tasks

1. Create a Service named `backend-svc` in namespace `ckad-svc-clusterip` that enables other in-cluster applications to reach the backend pods on port 80.
2. The service must select pods labeled `app=backend` and forward traffic to port 80 on those pods.
3. The service must not be accessible from outside the cluster.

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

You can create a service imperatively:
```bash
kubectl expose deployment backend --name=backend-svc --port=80 --target-port=80 -n ckad-svc-clusterip
```
</details>

<details>
<summary>Hint 2</summary>

Or declaratively with YAML:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: ckad-svc-clusterip
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 80
```
</details>

<details>
<summary>Hint 3</summary>

Verify your service endpoints:
```bash
kubectl get endpoints backend-svc -n ckad-svc-clusterip
```
The endpoints should show 2 pod IPs since the deployment has 2 replicas.
</details>
