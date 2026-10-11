# Exercise 30: Advanced Network Policies

**Difficulty:** Hard
**Domain:** 5 - Services and Networking
**Namespace:** `ckad-netpol-adv`

## Context

Your namespace `ckad-netpol-adv` runs a three-tier application: a frontend (`tier=web`), a backend API (`tier=api`, port 8080), and a database (`tier=data`, port 5432). A monitoring pod in the separate namespace `ckad-netpol-external` also needs access to the backend.

Implement a comprehensive network security posture with the following policies:

**Note:** Network Policies require a CNI plugin that supports them (e.g., Calico, Cilium). The policies will be created but may not be enforced without a compatible CNI.

## Setup

```bash
./setup.sh
```

## Tasks

1. **Backend protection** (`backend-policy`): The API layer should only accept incoming connections on port 8080 from two sources: frontend pods in the same namespace, and any pod from the `ckad-netpol-external` namespace. All other inbound traffic to the API must be denied.

2. **Database lockdown** (`database-policy`): The database is the most sensitive tier. It should only accept incoming connections on port 5432 from the API pods in the same namespace. For outbound traffic, the database should only be allowed to make DNS lookups (UDP port 53) — all other egress must be blocked.

3. **Default deny** (`default-deny-ingress`): As a baseline, all pods in the namespace should deny inbound traffic by default. The specific allow rules above take precedence for the pods they target.

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

For `backend-policy`, you need two separate `from` entries in the ingress rule to allow traffic from two different sources:
```yaml
ingress:
  - from:
      - podSelector:
          matchLabels:
            tier: web
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: ckad-netpol-external
    ports:
      - port: 8080
        protocol: TCP
```
Note: Items in the `from` array are OR'd together.
</details>

<details>
<summary>Hint 2</summary>

For `database-policy` egress to DNS only, you need to allow UDP port 53:
```yaml
egress:
  - ports:
      - port: 53
        protocol: UDP
```
And include both `Ingress` and `Egress` in `policyTypes`.
</details>

<details>
<summary>Hint 3</summary>

A default deny all ingress policy uses an empty `podSelector` and no `ingress` rules:
```yaml
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```
With no `ingress` field (or an empty array), all ingress is denied for all pods.
</details>

<details>
<summary>Hint 4</summary>

The `namespaceSelector` matches namespaces by their labels, not by name directly. However, Kubernetes automatically adds a `kubernetes.io/metadata.name` label to every namespace matching its name. So use:
```yaml
namespaceSelector:
  matchLabels:
    kubernetes.io/metadata.name: ckad-netpol-external
```
</details>
