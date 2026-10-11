# Exercise 22: Security Context

**Difficulty:** Medium
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-secctx`

## Context

The security team has mandated strict policies for all application pods running in the cluster. These requirements aim to reduce the attack surface by enforcing non-root execution, preventing privilege escalation, and protecting the container filesystem from unauthorized modification.

## Tasks

1. Deploy a pod named `secure-pod` in namespace `ckad-secctx` (image `busybox:1.36`, container name `secure-container`, command: `["sleep", "3600"]`) that meets the following security requirements:

   - All processes in the pod must run as user ID 1000 (not root), with primary group 3000.
   - All files created on mounted volumes must be owned by group ID 2000.
   - The container must not be able to gain additional privileges beyond what it starts with.
   - The container's root filesystem must be read-only to prevent tampering.

2. The application needs a writable temporary directory at `/tmp` despite the read-only filesystem restriction. Provide a suitable ephemeral volume named `tmp-vol` mounted at that path.

## Hints

<details>
<summary>Hint 1</summary>

Pod-level security context goes under `spec.securityContext`, while container-level goes under `spec.containers[].securityContext`.
</details>

<details>
<summary>Hint 2</summary>

```yaml
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: secure-container
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
```
</details>

<details>
<summary>Hint 3</summary>

An emptyDir volume provides a writable directory even with `readOnlyRootFilesystem: true`:
```yaml
volumes:
- name: tmp-vol
  emptyDir: {}
```
Mount it at `/tmp` in the container's `volumeMounts`.
</details>

<details>
<summary>Hint 4</summary>

Verify the user with:
```bash
kubectl exec secure-pod -n ckad-secctx -- id
```
Expected output: `uid=1000 gid=3000 groups=2000`
</details>
