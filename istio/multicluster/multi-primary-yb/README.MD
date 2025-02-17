## cluster1 (name-clu1): 
us-west region and in this demo acting as a primary cluster.

## cluster2 (name-clu2): 
us-east region and in this demo acting as a DR cluster.

## Scenario: 
Traffic for services should stay within a local regional cluster. The traffic type is either local originated traffic (east-west traffic between services) or traffic that is coming via istio-ingress.

----------------------
### Verification of cluster1:
```console
k1 get nodes -L topology.kubernetes.io/region
NAME                 STATUS   ROLES           AGE   VERSION   REGION
clu1-control-plane   Ready    control-plane   53m   v1.27.3   us-west
clu1-worker          Ready    <none>          52m   v1.27.3   us-west
clu1-worker2         Ready    <none>          52m   v1.27.3   us-west
```

### Verification of cluster2:
```console
k2 get nodes -L topology.kubernetes.io/region
NAME                 STATUS   ROLES           AGE   VERSION   REGION
clu2-control-plane   Ready    control-plane   53m   v1.27.3   us-east
clu2-worker          Ready    <none>          53m   v1.27.3   us-east
clu2-worker2         Ready    <none>          53m   v1.27.3   us-east
```

There are few types of locality based load-balancing, in this demo, we will be showing failover based on locality.
As a demo app, we have deployed helloworld version1 in cluster1 and version2 in cluster2.
Traffic flow without enabling locality based load balancing from cluster1.

```console
k1 exec -it deploy/sleep -- sh
~ $ curl -s helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-bfb69958d-w7lll
~ $ curl -s helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-7dd7df5884-4vgrt
```

We can see traffic is being load-balance to both cluster using a sleep pod in cluster1. This is happening because istio merge the endpoints of cluster1 and cluster2.

Let's check the traffic flow after enabling locality-based failover for hellworld service.

```console
curl -s helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-bfb69958d-w7lll
~ $ curl -s helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-bfb69958d-w7lll
~ $ curl -s helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-bfb69958d-w7lll
~ $ curl -s helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-bfb69958d-w7lll
```

We can see traffic is staying within cluster1 region.

Let's make the number of replicas of helloworld deployment in cluster1 to zero.

```console
~ $ curl -s helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-bfb69958d-w7lll
~ $ curl -s helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-bfb69958d-w7lll
~ $ 
~ $ curl -s helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-7dd7df5884-4vgrt
~ $ curl -s helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-7dd7df5884-4vgrt
```

We can see the traffic failed over to cluster2.