# Exercise 38: Image Pull Policy and Graceful Termination

**Difficulty:** Medium
**Domain:** Application Design and Build
**Namespace:** `ckad-pullpolicy`

## Context

Deployment `harvester` in namespace `ckad-pullpolicy` runs an application container together with a sidecar. To keep node bandwidth down and startup fast, the images should only be pulled when strictly necessary. The app also needs extra time to flush its work on shutdown, so pods must be given a longer grace period before being killed.

## Setup

```bash
./setup.sh
```

This creates the Deployment `harvester` with two containers: `app` and `sidecar`.

## Tasks

1. Configure the **app** container so it only pulls its image if it is **not already present** on the node.
2. Configure the **sidecar** container so it **never** pulls its image.
3. Give pods up to **60 seconds** to shut down gracefully on termination.

## Hints

<details>
<summary>Hint 1</summary>

Container image pull behaviour is controlled by `spec.template.spec.containers[].imagePullPolicy`. Valid values are `Always`, `IfNotPresent`, and `Never`.
</details>

<details>
<summary>Hint 2</summary>

- "pull only if not already present" → `imagePullPolicy: IfNotPresent`
- "never pull" → `imagePullPolicy: Never`
</details>

<details>
<summary>Hint 3</summary>

The grace period is a pod-level field: `spec.template.spec.terminationGracePeriodSeconds: 60`. Edit with `kubectl edit deployment harvester -n ckad-pullpolicy`.
</details>

## Verify

```bash
./verify.sh
```
