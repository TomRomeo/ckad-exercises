# Exercise 03: Multi-Container Pod (Sidecar Pattern)

**Difficulty:** Medium
**Domain:** Application Design and Build
**Namespace:** `ckad-multi-container`

## Context

Your application writes log entries to a file on disk, but the central logging system expects logs on stdout. You need to add a log-shipping container that runs next to the application and tails its log file to stdout. Use a Kubernetes native sidecar container so it starts before the main application and keeps running for the pod's whole lifetime. Both containers need access to the same log directory.

## Tasks

1. Create a pod named `sidecar-pod` in the `ckad-multi-container` namespace.
2. The main application container, named `app`, runs the `busybox:1.36` image and writes a timestamped log entry to `/var/log/app.log` every 5 seconds using the command: `sh -c 'while true; do echo "$(date) - Application log entry" >> /var/log/app.log; sleep 5; done'`
3. A log-shipping sidecar container named `sidecar` runs the `busybox:1.36` image and streams the application log to stdout using the command: `sh -c 'tail -f /var/log/app.log'`
4. The sidecar must be a Kubernetes native sidecar container, so it starts before the main application and keeps running alongside it for the pod's lifetime.
5. Both containers must share a volume named `log-volume` mounted at `/var/log` so the sidecar can read what the application writes.

## Hints

<details>
<summary>Hint 1</summary>

Native sidecar containers are defined under `spec.initContainers` with `restartPolicy: Always`. This distinguishes them from regular init containers (which run to completion and exit).
</details>

<details>
<summary>Hint 2</summary>

An emptyDir volume is defined in `spec.volumes`:
```yaml
volumes:
- name: log-volume
  emptyDir: {}
```
</details>

<details>
<summary>Hint 3</summary>

The pod spec should look like this structure:
```yaml
spec:
  initContainers:
  - name: sidecar
    image: busybox:1.36
    restartPolicy: Always    # This makes it a sidecar
    command: [...]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  containers:
  - name: app
    image: busybox:1.36
    command: [...]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
```
</details>
