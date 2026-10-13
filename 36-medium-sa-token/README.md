# Exercise 36: Decode a ServiceAccount Token

**Difficulty:** Medium
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-sa-token`

## Context

The backend team has its own ServiceAccount named `backend-sa-v2` in the `ckad-sa-token` namespace, along with a token Secret that belongs to it. A coworker on another system needs the raw (base64-decoded) token value from that Secret so they can authenticate against the API.

## Setup

```bash
./setup.sh
```

This creates the namespace `ckad-sa-token`, the ServiceAccount `backend-sa-v2`, and a `kubernetes.io/service-account-token` Secret named `backend-sa-v2-token` bound to it. It also creates the output directory `/tmp/ckad-sa-token`.

## Tasks

1. Find the token stored in the Secret that belongs to ServiceAccount `backend-sa-v2`.
2. Write the **base64-decoded** token to the file `/tmp/ckad-sa-token/token`.

## Hints

<details>
<summary>Hint 1</summary>

Inspect the secret and its keys:
```
kubectl get secret backend-sa-v2-token -n ckad-sa-token -o yaml
```
The token lives under `data.token` and is base64-encoded.
</details>

<details>
<summary>Hint 2</summary>

`kubectl get ... -o jsonpath` returns the raw base64 string; pipe it through `base64 -d` (or `base64 --decode`):
```
kubectl get secret backend-sa-v2-token -n ckad-sa-token -o jsonpath='{.data.token}' | base64 -d
```
</details>

<details>
<summary>Hint 3</summary>

Redirect the decoded output into the target file:
```
kubectl get secret backend-sa-v2-token -n ckad-sa-token -o jsonpath='{.data.token}' | base64 -d > /tmp/ckad-sa-token/token
```
</details>

## Verify

```bash
./verify.sh
```
