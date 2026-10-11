# Exercise 23: ServiceAccount Configuration

**Difficulty:** Medium
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-sa`

## Context

Your application pod needs a dedicated identity for audit trail purposes, but the application itself does not communicate with the Kubernetes API. The security team requires that pods run under named service accounts (not the default) and that unnecessary API access is removed.

## Tasks

1. Create a ServiceAccount named `app-sa` in namespace `ckad-sa`.

2. Deploy a pod named `sa-pod` (image `nginx:1.25`, container name `app`) in namespace `ckad-sa` running under the `app-sa` identity.

3. For security, ensure the pod does not have Kubernetes API credentials automatically available inside the container — the application does not need them.

## Hints

<details>
<summary>Hint 1</summary>

Create a ServiceAccount imperatively:
```bash
kubectl create serviceaccount app-sa -n ckad-sa
```
</details>

<details>
<summary>Hint 2</summary>

Set the ServiceAccount and disable token mounting in the pod spec:
```yaml
spec:
  serviceAccountName: app-sa
  automountServiceAccountToken: false
  containers:
  - name: app
    image: nginx:1.25
```
</details>

<details>
<summary>Hint 3</summary>

To verify no token is mounted:
```bash
kubectl exec sa-pod -n ckad-sa -- ls /var/run/secrets/kubernetes.io/serviceaccount 2>&1
```
This should return an error (directory not found) if token mounting is disabled.
</details>
