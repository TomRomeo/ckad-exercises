# Exercise 20: Secret Basics

**Difficulty:** Easy
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-secret`

## Context

Your application needs database credentials that must be stored securely, not in plain ConfigMaps. The operations team has asked that these credentials be made available as files inside the application container rather than as environment variables, to reduce the risk of accidental exposure through logs or process listings.

## Tasks

1. Create a Secret named `db-credentials` in namespace `ckad-secret` containing the following sensitive values:
   - A username: `admin`
   - A password: `S3cur3P@ss!`

2. Deploy a pod named `secret-pod` (image `nginx:1.25`, container name `app`) where the credentials are available as files in the `/etc/secrets` directory. Use a volume named `secret-vol` for this purpose.

## Hints

<details>
<summary>Hint 1</summary>

Create a Secret imperatively:
```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal='password=S3cur3P@ss!' \
  -n ckad-secret
```
</details>

<details>
<summary>Hint 2</summary>

To mount a Secret as a volume:
```yaml
spec:
  volumes:
  - name: secret-vol
    secret:
      secretName: db-credentials
  containers:
  - name: app
    image: nginx:1.25
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secrets
      readOnly: true
```
</details>

<details>
<summary>Hint 3</summary>

Verify the mounted files:
```bash
kubectl exec secret-pod -n ckad-secret -- ls /etc/secrets
kubectl exec secret-pod -n ckad-secret -- cat /etc/secrets/username
```
</details>
