# Exercise 31: Job with Completions and Parallelism

**Difficulty:** Easy
**Domain:** Application Design and Build
**Namespace:** `ckad-job`

## Context

The batch-processing team runs a workload that must process a fixed number of work items. Unlike a long-running web server, this task should run to completion a set number of times, with a couple of pods working in parallel to finish faster. Completed runs must be kept in history so operators can inspect them afterwards.

## Tasks

1. Create a Job named `batch-job` in the `ckad-job` namespace.
2. The container must be named `batch-job-container`, use image `busybox:1.36`, and run the command `sh -c 'sleep 2 && echo done'`.
3. The Job must reach **3** successful completions in total, with **2** pods running in parallel.
4. The pods created by the Job must carry the label `id: awesome-job`.

## Hints

<details>
<summary>Hint 1</summary>

Generate a Job skeleton with:
```
kubectl create job batch-job --image=busybox:1.36 -n ckad-job --dry-run=client -o yaml -- sh -c 'sleep 2 && echo done'
```
</details>

<details>
<summary>Hint 2</summary>

`completions` and `parallelism` are fields under `spec` of the Job (not inside the pod template). Set `spec.completions: 3` and `spec.parallelism: 2`.
</details>

<details>
<summary>Hint 3</summary>

The pod label goes under `spec.template.metadata.labels`. The container name is set with `spec.template.spec.containers[0].name`. Remember a Job's pod `restartPolicy` must be `Never` or `OnFailure`.
</details>

## Verify

```bash
./verify.sh
```
