# Exercise 05: PersistentVolume and PersistentVolumeClaim

**Difficulty:** Medium
**Domain:** Application Design and Build
**Namespace:** `ckad-volumes`

## Context

Your application needs persistent storage that survives pod restarts. The infrastructure team has allocated a host directory at `/tmp/ckad-data` on the node for this purpose. You need to provision storage from this directory, claim a portion of it for your application, and mount it into a pod. The storage uses manual provisioning, since this cluster has no dynamic storage provisioner.

## Tasks

1. Provision a cluster-level storage resource named `ckad-pv` backed by the host directory `/tmp/ckad-data`. It should offer **1Gi** of capacity with single-node read-write access, using the storage class `manual`.
2. In the `ckad-volumes` namespace, create a storage claim named `ckad-pvc` that requests **500Mi** of capacity with single-node read-write access from the `manual` storage class. It should bind to the provisioned storage.
3. Deploy a pod named `pv-pod` in the `ckad-volumes` namespace running `nginx:1.25`. The pod should use the claimed storage (referenced through a volume named `data-volume`) and mount it at `/data` inside the container.

## Hints

<details>
<summary>Hint 1</summary>

PersistentVolumes are cluster-scoped (no namespace). PersistentVolumeClaims are namespaced.
</details>

<details>
<summary>Hint 2</summary>

The PVC will bind to the PV if the storage class, access mode, and capacity are compatible. The PVC requests 500Mi and the PV offers 1Gi, so it will bind.
</details>

<details>
<summary>Hint 3</summary>

In the pod spec, reference the PVC like this:
```yaml
volumes:
- name: data-volume
  persistentVolumeClaim:
    claimName: ckad-pvc
```
</details>
