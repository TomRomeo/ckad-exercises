# Exercise 11: Helm Basics

**Difficulty:** Medium
**Domain:** Application Deployment
**Namespace:** `ckad-helm`

## Context

Your team uses Helm for package management across all Kubernetes environments. A new project requires an nginx web server, and rather than writing manifests from scratch, you should use the official Bitnami chart from their public repository. The application needs multiple replicas for availability.

## Prerequisites

- `helm` CLI must be installed. You can verify with `helm version`.

## Setup

```bash
./setup.sh
```

## Tasks

1. Add the Bitnami Helm chart repository (`https://charts.bitnami.com/bitnami`) to your local Helm configuration
2. Deploy an nginx web server by installing a release named `my-nginx` in the `ckad-helm` namespace using the `bitnami/nginx` chart
3. The application requires 2 replicas for availability
4. Confirm the release is deployed and the pods are running

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

Add a Helm repository:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
</details>

<details>
<summary>Hint 2</summary>

Install a chart with custom values:
```bash
helm install my-nginx bitnami/nginx --namespace ckad-helm --set replicaCount=2
```
</details>

<details>
<summary>Hint 3</summary>

Check the release status:
```bash
helm list -n ckad-helm
helm status my-nginx -n ckad-helm
```

Check running pods:
```bash
kubectl get pods -n ckad-helm
kubectl get deployment -n ckad-helm
```
</details>
