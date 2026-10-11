# Exercise 28: Create a Network Policy

**Difficulty:** Medium
**Domain:** 5 - Services and Networking
**Namespace:** `ckad-netpol`

## Context

Three application tiers are running in the `ckad-netpol` namespace: a web frontend (`app=web`), an API layer (`app=api`), and a database (`app=db`). The security team requires that the database pods are only accessible from the API layer — no other pods (including the frontend) should be able to connect to the database directly.

Create a NetworkPolicy named `db-policy` that restricts incoming traffic to the database pods so only the API pods can reach them on port 80. Outbound traffic from the database should not be restricted.

**Note:** Network Policies require a CNI plugin that supports them (e.g., Calico, Cilium, Weave Net). If your cluster uses a CNI that doesn't support NetworkPolicy (e.g., basic Flannel), the policies will be created but not enforced.

## Setup

```bash
./setup.sh
```

## Tasks

1. Create a NetworkPolicy named `db-policy` in namespace `ckad-netpol` that targets the database pods (labeled `app=db`).
2. The policy must ensure that only pods from the API layer (labeled `app=api`) can send traffic to the database on port 80.
3. All other incoming traffic to the database pods must be denied.
4. Outbound traffic from the database pods must remain unrestricted.

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

A NetworkPolicy that specifies `policyTypes: ["Ingress"]` with specific ingress rules will deny all ingress traffic except what is explicitly allowed.
</details>

<details>
<summary>Hint 2</summary>

The basic structure of a NetworkPolicy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: ckad-netpol
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: api
      ports:
        - port: 80
          protocol: TCP
```
</details>

<details>
<summary>Hint 3</summary>

Remember: By only specifying `Ingress` in `policyTypes` and not including `Egress`, the egress traffic remains unrestricted.
</details>
