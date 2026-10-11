# Exercise 25: RBAC - Roles and RoleBindings

**Difficulty:** Hard
**Domain:** Application Environment, Configuration, and Security
**Namespace:** `ckad-rbac`

## Context

A developer ServiceAccount `dev-user` has been created in the `ckad-rbac` namespace by the setup script. The security team needs to grant this account specific permissions following the principle of least privilege — only the access required for the developer's workflow, nothing more.

## Tasks

1. The developer needs **read-only access to pods** — they should be able to view pods and their logs, but not modify or delete them. Create a Role named `pod-reader` that grants this access, and bind it to `dev-user` with a RoleBinding named `dev-user-pod-reader`.

2. The developer also needs **full management access to Deployments** (in the `apps` API group) — they should be able to view, create, update, and delete Deployments. Create a Role named `deploy-manager` that grants this access, and bind it to `dev-user` with a RoleBinding named `dev-user-deploy-manager`.

3. Verify that `dev-user` can get pods and manage deployments, but cannot delete pods or create services.

## Hints

<details>
<summary>Hint 1</summary>

Create a Role imperatively:
```bash
kubectl create role pod-reader --verb=get,list,watch --resource=pods,pods/log -n ckad-rbac
```
</details>

<details>
<summary>Hint 2</summary>

Create a RoleBinding imperatively:
```bash
kubectl create rolebinding dev-user-pod-reader --role=pod-reader --serviceaccount=ckad-rbac:dev-user -n ckad-rbac
```
</details>

<details>
<summary>Hint 3</summary>

Test permissions with `kubectl auth can-i`:
```bash
kubectl auth can-i get pods --as=system:serviceaccount:ckad-rbac:dev-user -n ckad-rbac
kubectl auth can-i delete pods --as=system:serviceaccount:ckad-rbac:dev-user -n ckad-rbac
```
</details>

<details>
<summary>Hint 4</summary>

Role YAML for deploy-manager:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deploy-manager
  namespace: ckad-rbac
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "delete"]
```
</details>
