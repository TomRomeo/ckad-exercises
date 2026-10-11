# Exercise 13: Pod Logs

**Difficulty:** Easy
**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-logs`

## Context

An incident has been reported for an application running in the `ckad-logs` namespace. The on-call engineer needs you to capture recent log output from the pod for analysis. The pod `log-generator` continuously writes timestamped entries to stdout and is the primary source of diagnostic information for this service.

## Setup

Run the setup script to create the namespace and deploy the log-generating pod:

```bash
./setup.sh
```

## Tasks

1. A pod named `log-generator` in the `ckad-logs` namespace is producing application logs. Retrieve the most recent 10 lines of log output from this pod.
2. Save those 10 lines to the file `/tmp/ckad-logs-output.txt` on your local machine.
3. Confirm the captured output contains at least one log entry with the text `INFO log-line`.

## Hints

<details>
<summary>Hint 1</summary>
Use `kubectl logs` to view pod logs. The `-n` flag specifies the namespace.
</details>

<details>
<summary>Hint 2</summary>
Use `kubectl logs --tail=10` to retrieve only the last 10 lines of logs.
</details>

<details>
<summary>Hint 3</summary>
Redirect output to a file with `>`, e.g.: `kubectl logs --tail=10 -n ckad-logs log-generator > /tmp/ckad-logs-output.txt`
</details>

## Verify

```bash
./verify.sh
```
