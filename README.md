# CKAD Practice Exercises

30 hands-on exercises covering all 5 CKAD (Certified Kubernetes Application Developer) exam domains, graded automatically just like the real exam.

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

## Difficulty Distribution

- **Easy** (10 exercises): Fundamental concepts, single-resource tasks
- **Medium** (14 exercises): Multi-step tasks, combining resources
- **Hard** (6 exercises): Complex scenarios, multiple resources, troubleshooting

## Scoring

The `verify-all.sh` script grades all exercises and reports a percentage score. The real CKAD exam requires **66%** to pass. Each exercise is worth equal weight.

## Tips

- Set up exercises individually with `./NN-exercise-name/setup.sh` or all at once with `./setup-all.sh`
- Each exercise is independent — work on them in any order
- Use `kubectl explain <resource>` and the [Kubernetes docs](https://kubernetes.io/docs/) (allowed during the real exam)
- Practice using `kubectl run`, `kubectl create`, and `--dry-run=client -o yaml` for speed
- Time yourself — the real exam gives ~2 hours for 15-20 tasks
