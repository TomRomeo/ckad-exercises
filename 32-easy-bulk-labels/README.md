# Exercise 32: Bulk Labels and Annotations by Selector

**Difficulty:** Easy
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-labels`

## Context

An audit in the `ckad-labels` namespace needs to mark certain workloads as protected so an automated cleanup job skips them. The protected workloads are the ones already classified as `worker` or `runner`. Once marked, they also need a human-readable annotation warning operators not to delete them.

## Setup

```bash
./setup.sh
```

This creates several pods in the `ckad-labels` namespace with an existing `type` label of `worker`, `runner`, or `other`.

## Tasks

1. Add the label `protected=true` to **all pods** that currently have a `type` label of `worker` **or** `runner`. Pods with `type=other` must NOT be changed.
2. Then add the annotation `protected=do not delete this pod` to **all pods** that now carry the `protected=true` label.

## Hints

<details>
<summary>Hint 1</summary>

`kubectl label` accepts a label selector with `-l`. You can run it twice (once per matching type), for example:
```
kubectl label pod -n ckad-labels -l type=worker protected=true
kubectl label pod -n ckad-labels -l type=runner protected=true
```
</details>

<details>
<summary>Hint 2</summary>

`kubectl annotate` works the same way and also accepts `-l`:
```
kubectl annotate pod -n ckad-labels -l protected=true protected="do not delete this pod"
```
</details>

<details>
<summary>Hint 3</summary>

Verify your selection first with `kubectl get pods -n ckad-labels --show-labels` before applying changes. Annotation values containing spaces must be quoted.
</details>

## Verify

```bash
./verify.sh
```
