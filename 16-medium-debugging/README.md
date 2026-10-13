# Exercise 16: Debugging a Broken Pod

**Difficulty:** Medium
**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-debug`

## Context

A colleague deployed a pod to the `ckad-debug` namespace but it never reached a healthy state. They've asked you to take over and get the application running. You need to investigate the issue using standard Kubernetes debugging tools, identify the root cause, and fix it.

## Setup

Run the setup script to create the namespace and deploy the broken pod:

```bash
./setup.sh
```

## Tasks

1. The pod `broken-pod` in namespace `ckad-debug` is not running. Investigate the issue using standard Kubernetes debugging techniques to identify the root cause.
2. Fix the pod so it runs successfully under the same pod name `broken-pod`.
3. Confirm the pod reaches a healthy Running state.

## Hints

<details>
<summary>Hint 1</summary>
Use `kubectl describe pod broken-pod -n ckad-debug` to see events and status details. Look at the "Events" section at the bottom of the output.
</details>

<details>
<summary>Hint 2</summary>
The issue is with the container image. Check the image name in the pod spec. Is it a valid, pullable image?
</details>

<details>
<summary>Hint 3</summary>

```bash
kubectl delete pod broken-pod -n ckad-debug
kubectl run broken-pod --image=nginx:1.25 -n ckad-debug
```
</details>

## Verify

```bash
./verify.sh
```
