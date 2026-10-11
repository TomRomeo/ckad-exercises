# Exercise 29: Create an Ingress Resource

**Difficulty:** Medium
**Domain:** 5 - Services and Networking
**Namespace:** `ckad-ingress`

## Context

Two applications are running in the `ckad-ingress` namespace: a web app (`web-svc` on port 80) and an API service (`api-svc` on port 80). External users need to access both applications through a single hostname `myapp.example.com`, with traffic routed based on the URL path: requests to `/web` should go to the web application, and requests to `/api` should go to the API service.

Create an Ingress resource named `app-ingress` using the `nginx` ingress class. Paths should match on prefix.

**Note:** An Ingress controller (e.g., nginx-ingress-controller) must be installed in your cluster for Ingress resources to work. The Ingress resource will be created regardless, but routing will only function with a controller present.

## Setup

```bash
./setup.sh
```

## Tasks

1. Create an Ingress resource named `app-ingress` in namespace `ckad-ingress` that routes external traffic to the two backend services based on URL path.
2. All traffic must be routed under the hostname `myapp.example.com`.
3. Requests to `/web` should be sent to `web-svc` on port 80, and requests to `/api` should be sent to `api-svc` on port 80. Both paths should use prefix-based matching.
4. The Ingress must use the `nginx` ingress class.

## Verify

```bash
./verify.sh
```

## Hints

<details>
<summary>Hint 1</summary>

You can generate a starting point with:
```bash
kubectl create ingress app-ingress \
  --class=nginx \
  --rule="myapp.example.com/web=web-svc:80" \
  --rule="myapp.example.com/api=api-svc:80" \
  -n ckad-ingress \
  --dry-run=client -o yaml
```
Then set pathType to Prefix.
</details>

<details>
<summary>Hint 2</summary>

The Ingress spec with path-based routing:
```yaml
spec:
  ingressClassName: nginx
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /web
            pathType: Prefix
            backend:
              service:
                name: web-svc
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-svc
                port:
                  number: 80
```
</details>

<details>
<summary>Hint 3</summary>

Full example manifest:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: ckad-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /web
            pathType: Prefix
            backend:
              service:
                name: web-svc
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-svc
                port:
                  number: 80
```
</details>
