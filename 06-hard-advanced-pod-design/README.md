# Exercise 06: Advanced Pod Design

**Difficulty:** Hard
**Domain:** Application Design and Build
**Namespace:** `ckad-adv-pod`

## Context

You are deploying a production application pod that combines several Kubernetes patterns. The application requires a one-time initialization step to prepare configuration files before the main app starts, a continuously running log-streaming sidecar, and the main web server itself. The ConfigMap `app-config` and Secret `app-secret` have already been created in the namespace by the platform team.

## Tasks

1. Create a pod named `advanced-pod` in the `ckad-adv-pod` namespace.

2. **Configuration initialization:** Before anything else runs, a one-time setup step (container named `config-init`, image `busybox:1.36`) must copy the configuration file from the ConfigMap's mount location to a shared working directory. The command is: `sh -c 'cp /config/config.json /app-config/config.json'`. It reads from a volume named `config-volume` (mounted at `/config`) that is populated from the `app-config` ConfigMap, and writes to a shared volume named `app-config-volume` (mounted at `/app-config`). This step runs once to completion and does not restart.

3. **Log streaming sidecar:** A container named `logger` (image `busybox:1.36`) must stream the application's access log to stdout using the command: `sh -c 'touch /var/log/app/access.log && tail -f /var/log/app/access.log'`. It shares a volume named `log-volume` (mounted at `/var/log/app`) with the main application. This sidecar must start before the main application and keep running alongside it for the pod's whole lifetime, so implement it as a Kubernetes native sidecar container.

4. **Main application:** The web server container named `app` runs `nginx:1.25` and serves traffic on port **80**. It needs access to three volumes: the shared log directory `log-volume` at `/var/log/app`, the prepared configuration `app-config-volume` at `/app-config`, and sensitive credentials from the `app-secret` Secret via a volume named `secret-volume` at `/secrets`. To ensure fair cluster scheduling, the container should request **100m** CPU and **128Mi** memory, with upper limits of **200m** CPU and **256Mi** memory.

5. The pod uses four volumes total: `log-volume` and `app-config-volume` are ephemeral scratch volumes, `config-volume` is backed by the `app-config` ConfigMap, and `secret-volume` is backed by the `app-secret` Secret.

## Hints

<details>
<summary>Hint 1</summary>

The `initContainers` section should contain **two** entries:
- `config-init`, a regular init container (no `restartPolicy` override, runs to completion)
- `logger`, a native sidecar (has `restartPolicy: Always`)

Order matters: `config-init` must come before `logger` so the config is copied before the sidecar starts.
</details>

<details>
<summary>Hint 2</summary>

A ConfigMap volume is defined as:
```yaml
- name: config-volume
  configMap:
    name: app-config
```
A Secret volume is defined as:
```yaml
- name: secret-volume
  secret:
    secretName: app-secret
```
</details>

<details>
<summary>Hint 3</summary>

Resource requests and limits go under `resources` in the container spec:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "200m"
    memory: "256Mi"
```
</details>

<details>
<summary>Hint 4</summary>

The logger uses `touch` to create the log file before tailing it. This prevents `tail -f` from failing on a non-existent file. The pod should be fully healthy after correct setup.
</details>
