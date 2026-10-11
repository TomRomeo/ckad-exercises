# Exercise 40: ConfigMap Housekeeping by Label

**Difficulty:** Easy
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-housekeeping1`, `ckad-housekeeping2`

## Context

Some manual ConfigMap housekeeping is due across two project namespaces. One namespace needs an audit count of its cache ConfigMaps; the other needs its expired ConfigMaps cleaned out. Both tasks are driven entirely by labels.

## Setup

```bash
./setup.sh
```

This creates:
- Namespace `ckad-housekeeping1` with several ConfigMaps, some labelled `purpose=cache`
- Namespace `ckad-housekeeping2` with several ConfigMaps, some labelled `purpose=expired`
- The output directory `/tmp/ckad-housekeeping`

## Tasks

1. In namespace `ckad-housekeeping1`, count the ConfigMaps that have the label `purpose=cache` and write **just that number** to `/tmp/ckad-housekeeping/cf-count`.
2. In namespace `ckad-housekeeping2`, delete **all** ConfigMaps with the label `purpose=expired`.

## Hints

<details>
<summary>Hint 1</summary>

Filter by label and count the lines (skip the header with `--no-headers`):
```
kubectl get cm -n ckad-housekeeping1 -l purpose=cache --no-headers | wc -l
```
</details>

<details>
<summary>Hint 2</summary>

Write just the number into the file:
```
kubectl get cm -n ckad-housekeeping1 -l purpose=cache --no-headers | wc -l | tr -d ' ' > /tmp/ckad-housekeeping/cf-count
```
</details>

<details>
<summary>Hint 3</summary>

`kubectl delete` accepts a label selector too:
```
kubectl delete cm -n ckad-housekeeping2 -l purpose=expired
```
</details>

## Verify

```bash
./verify.sh
```
