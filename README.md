# CKAD Practice Exercises

40 hands-on exercises covering all 5 CKAD (Certified Kubernetes Application Developer) exam domains, graded automatically just like the real exam. Exercises 31-40 are modelled on realistic exam-simulation scenarios to round out coverage.

## Prerequisites

- A running Kubernetes cluster (minikube, kind, k3s, etc.)
- `kubectl` configured and connected
- `helm` (for exercise 11 only)

## Quick Start

```bash
# 1. Set up ALL exercises at once
./setup-all.sh

# 2. Work through exercises (read each README.md)
cat 01-easy-pod-design/README.md

# 3. Verify your solution
./01-easy-pod-design/verify.sh

# 4. Verify ALL exercises (exam simulation)
./verify-all.sh

# 5. Clean up when done
./cleanup.sh
```

## Interactive TUI

Prefer a terminal UI over juggling files? Launch the built-in TUI (requires Go):

```bash
./tui.sh
```

It discovers all exercises dynamically and lets you:

- Browse the exercise list (filter by typing `/`), with difficulty badges and a
  `✓ solved` marker once an exercise's `verify.sh` passes.
- See a **progress bar** (solved / total) and a **session timer** at the top.
- Read the rendered exercise markdown in a scrollable pane.
- Jump to the **next/previous** exercise with `]` / `[` without leaving detail view.
- Reveal hints **one at a time** with `n` (press `N` to hide them again).
- Run `setup.sh` with `s` and the validation (`verify.sh`) with `v`. Verify
  output **streams live** (with ANSI colors preserved, running under a PTY)
  directly below the exercise markdown in the same scrollable pane.
- Enable **live verify** with `w`: it re-runs `verify.sh` quietly in the
  background every few seconds and updates the solved status automatically,
  so you can keep editing and watch it flip to passing.
- 🎉 **Confetti** rains down whenever an exercise first turns green (from either
  a manual `v` run or live verify).

Keys:

| Key | Action |
|-----|--------|
| `enter` | open exercise |
| `n` / `N` | reveal next hint / hide all hints |
| `v` | run `verify.sh` (live streaming output) |
| `w` | toggle live verify (auto re-run in background) |
| `s` | run `setup.sh` |
| `]` / `[` | next / previous exercise |
| `t` / `T` | start-pause timer / reset timer |
| `↑` `↓` | scroll |
| `esc` | back to list |
| `q` | quit |




## Exercise Overview

### Domain 1: Application Design and Build (20%)

| # | Exercise | Difficulty | Namespace |
|---|----------|-----------|-----------|
| 01 | Pod Design Basics | Easy | `ckad-pod-design` |
| 02 | CronJob | Easy | `ckad-cronjob` |
| 03 | Multi-Container Pod (Sidecar) | Medium | `ckad-multi-container` |
| 04 | Init Containers | Medium | `ckad-init-container` |
| 05 | PersistentVolume & PVC | Medium | `ckad-volumes` |
| 06 | Advanced Pod Design | Hard | `ckad-adv-pod` |

### Domain 2: Application Deployment (20%)

| # | Exercise | Difficulty | Namespace |
|---|----------|-----------|-----------|
| 07 | Deployment Basics | Easy | `ckad-deploy-basics` |
| 08 | Rolling Update | Easy | `ckad-rolling-update` |
| 09 | Rollback | Medium | `ckad-rollback` |
| 10 | Deployment Strategy | Medium | `ckad-deploy-strategy` |
| 11 | Helm Basics | Medium | `ckad-helm` |
| 12 | Canary Deployment | Hard | `ckad-canary` |

### Domain 3: Application Observability and Maintenance (15%)

| # | Exercise | Difficulty | Namespace |
|---|----------|-----------|-----------|
| 13 | Pod Logs | Easy | `ckad-logs` |
| 14 | Liveness Probe | Easy | `ckad-liveness` |
| 15 | Readiness Probe | Medium | `ckad-readiness` |
| 16 | Debugging Pods | Medium | `ckad-debug` |
| 17 | Startup Probe | Medium | `ckad-startup` |
| 18 | Troubleshooting | Hard | `ckad-troubleshoot` |

### Domain 4: Application Environment, Configuration, and Security (25%)

| # | Exercise | Difficulty | Namespace |
|---|----------|-----------|-----------|
| 19 | ConfigMap | Easy | `ckad-configmap` |
| 20 | Secret | Easy | `ckad-secret` |
| 21 | Resource Requests & Limits | Medium | `ckad-resources` |
| 22 | Security Context | Medium | `ckad-secctx` |
| 23 | ServiceAccount | Medium | `ckad-sa` |
| 24 | ResourceQuota & LimitRange | Medium | `ckad-quota` |
| 25 | RBAC | Hard | `ckad-rbac` |

### Domain 5: Services and Networking (20%)

| # | Exercise | Difficulty | Namespace |
|---|----------|-----------|-----------|
| 26 | ClusterIP Service | Easy | `ckad-svc-clusterip` |
| 27 | NodePort Service | Easy | `ckad-svc-nodeport` |
| 28 | Network Policy | Medium | `ckad-netpol` |
| 29 | Ingress | Medium | `ckad-ingress` |
| 30 | Advanced Network Policies | Hard | `ckad-netpol-adv` |

### Exam-Simulation Set

These exercises round out the set and fill gaps not
covered above (Jobs, HPA, blue-green, StorageClasses, Kustomize, bulk label ops, etc.).

| # | Exercise | Difficulty | Domain | Namespace |
|---|----------|-----------|--------|-----------|
| 31 | Job (Completions & Parallelism) | Easy | Design & Build | `ckad-job` |
| 32 | Bulk Labels & Annotations by Selector | Easy | Config & Security | `ckad-labels` |
| 33 | Blue-Green Deployment Cutover | Medium | Deployment | `ckad-bluegreen` |
| 34 | Fix a Deprecated HPA (+ memory metric) | Medium | Deployment | `ckad-hpa` |
| 35 | StorageClass & Pending PVC | Medium | Design & Build | `ckad-storageclass` |
| 36 | Decode a ServiceAccount Token | Medium | Config & Security | `ckad-sa-token` |
| 37 | Find a Pod by Label & Move It | Medium | Design & Build | `ckad-staging` and `ckad-shop` |
| 38 | Image Pull Policy & Graceful Termination | Medium | Design & Build | `ckad-pullpolicy` |
| 39 | Canary Rollout with Kustomize | Hard | Deployment | `ckad-kustomize` |
| 40 | ConfigMap Housekeeping by Label | Easy | Config & Security | `ckad-housekeeping1/2` |

> Exercises that write output files (34, 35, 36, 40) use paths under `/tmp/` on the machine
> running `kubectl`, mirroring exam-style "write the answer to a file" tasks.

## Difficulty Distribution

- **Easy** (13 exercises): Fundamental concepts, single-resource tasks
- **Medium** (20 exercises): Multi-step tasks, combining resources
- **Hard** (7 exercises): Complex scenarios, multiple resources, troubleshooting

## Scoring

The `verify-all.sh` script grades all exercises and reports a percentage score. The real CKAD exam requires **66%** to pass. Each exercise is worth equal weight.

## Tips

- Set up exercises individually with `./NN-exercise-name/setup.sh` or all at once with `./setup-all.sh`
- Each exercise is independent, so work on them in any order
- Use `kubectl explain <resource>` and the [Kubernetes docs](https://kubernetes.io/docs/) (allowed during the real exam)
- Practice using `kubectl run`, `kubectl create`, and `--dry-run=client -o yaml` for speed
- Time yourself. The real exam gives about 2 hours for 15-20 tasks
