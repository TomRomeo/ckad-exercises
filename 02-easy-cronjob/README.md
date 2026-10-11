# Exercise 02: CronJob Creation

**Difficulty:** Easy
**Domain:** Application Design and Build
**Namespace:** `ckad-cronjob`

## Context

The operations team needs a small monitoring job that runs on a schedule inside the cluster. The job prints a timestamp and a status message so operators can confirm the scheduler is working. To avoid filling up etcd with old job records, the team wants limits on how many completed and failed job runs are kept.

## Tasks

1. Create a CronJob named `date-printer` in the `ckad-cronjob` namespace using the `busybox:1.36` image.
2. The job should execute every minute on the schedule `*/1 * * * *`.
3. Each job run must execute the command: `date; echo "CKAD CronJob executed successfully"`
4. For storage efficiency, only the **3** most recent successful runs should be retained. Only **1** failed run should be kept.
5. If a container fails, it should not be restarted; the run is just recorded as failed.

## Hints

<details>
<summary>Hint 1</summary>

You can generate a CronJob manifest using:
```
kubectl create cronjob date-printer --image=busybox:1.36 --schedule="*/1 * * * *" --dry-run=client -o yaml
```
</details>

<details>
<summary>Hint 2</summary>

The command needs to be passed as a shell command. Use:
```yaml
command: ["sh", "-c", "date; echo \"CKAD CronJob executed successfully\""]
```
</details>

<details>
<summary>Hint 3</summary>

`successfulJobsHistoryLimit` and `failedJobsHistoryLimit` are set at the CronJob spec level, not inside the job template. The `restartPolicy` goes in `spec.jobTemplate.spec.template.spec`.
</details>
