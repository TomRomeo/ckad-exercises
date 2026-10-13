# Exercise 35: StorageClass and a Pending PVC

**Difficulty:** Medium
**Domain:** Application Design and Build
**Namespace:** `ckad-storageclass`

## Context

The storage team needs more storage with a provisioner that retains volumes after a claim is deleted. The provisioner itself will be installed later by another team, so the claim you create will stay `Pending` for now — that is expected. You should still capture the event message that explains why, so operators understand the pending state.

## Setup

```bash
./setup.sh
```

This creates the namespace `ckad-storageclass` and the output directory `/tmp/ckad-storageclass`.

## Tasks

1. Create a (cluster-scoped) StorageClass named `retain-sc` with:
   - `provisioner`: `custom-retainer`
   - `reclaimPolicy`: `Retain`
2. In namespace `ckad-storageclass`, create a PersistentVolumeClaim named `data-pvc` that:
   - uses `storageClassName: retain-sc`
   - has `accessModes: ReadWriteOnce`
   - requests `3Gi` of storage
3. Because the provisioner does not exist yet, the PVC will stay `Pending`. Write the PVC's event message explaining why into `/tmp/ckad-storageclass/pvc-reason`.

## Hints

<details>
<summary>Hint 1</summary>

A minimal StorageClass:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: retain-sc
provisioner: custom-retainer
reclaimPolicy: Retain
```
</details>

<details>
<summary>Hint 2</summary>

The PVC must reference the StorageClass by name with `spec.storageClassName: retain-sc`.
</details>

<details>
<summary>Hint 3</summary>

See the reason with `kubectl describe pvc data-pvc -n ckad-storageclass`, then capture it, e.g.:
```
kubectl describe pvc data-pvc -n ckad-storageclass | grep -A3 Events > /tmp/ckad-storageclass/pvc-reason
```
The message mentions waiting for a volume / provisioner.
</details>

## Verify

```bash
./verify.sh
```
