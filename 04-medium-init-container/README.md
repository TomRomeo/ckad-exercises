# Exercise 04: Init Containers

**Difficulty:** Medium
**Domain:** Application Design and Build
**Namespace:** `ckad-init-container`

## Context

Your application pod depends on a backend service called `init-svc` being available before it can start. If the application starts before the service is reachable, it crashes on boot. To prevent this, the pod must wait until `init-svc` is resolvable via cluster DNS before launching the main application. The service does not yet exist — you will need to create it so the pod can eventually transition to a running state.

## Tasks

1. Create a pod named `init-pod` in the `ckad-init-container` namespace.
2. The pod must not start its main application until the service `init-svc` is resolvable via DNS in the `ckad-init-container` namespace. Use `busybox:1.36` for the DNS check container (named `init-svc-check`) with the command: `sh -c 'until nslookup init-svc.ckad-init-container.svc.cluster.local; do echo waiting for service; sleep 2; done'`
3. Once the dependency check passes, the main application container named `main-app` should start running `nginx:1.25` and serve traffic on port **80**.
4. Create a ClusterIP Service named `init-svc` in the `ckad-init-container` namespace that listens on port **80** (targeting port **80**) and selects pods with the label `app=init`. This will make the DNS entry available, unblocking the pod.

## Hints

<details>
<summary>Hint 1</summary>

Init containers are defined in `spec.initContainers`, which has the same schema as `spec.containers`.
</details>

<details>
<summary>Hint 2</summary>

The pod will stay in `Init:0/1` status until the init container succeeds. Create the service to unblock it.
</details>

<details>
<summary>Hint 3</summary>

Create the service imperatively:
```
kubectl create service clusterip init-svc --tcp=80:80 -n ckad-init-container
```
Then edit it to add the correct selector `app=init`, or create it declaratively.
</details>
