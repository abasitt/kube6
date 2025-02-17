#!/bin/bash

# download docker images to a host
echo "Pulling metallb images to a docker host..."
docker pull quay.io/metallb/controller:v0.14.9
docker pull quay.io/metallb/speaker:v0.14.9

CLUSTER1_NAME=clu1
CLUSTER2_NAME=clu2
CLUSTER1_CTX=kind-clu1 
CLUSTER2_CTX=kind-clu2

# Load images to both clusters
echo "Loading metallb images to both clusters..."
kind load docker-image --name $CLUSTER1_NAME quay.io/metallb/controller:v0.14.9
kind load docker-image --name $CLUSTER1_NAME quay.io/metallb/controller:v0.14.9

kind load docker-image --name $CLUSTER2_NAME quay.io/metallb/speaker:v0.14.9
kind load docker-image --name $CLUSTER2_NAME quay.io/metallb/speaker:v0.14.9

# Install metallb using the latest version 13.10
echo "install metallb on $CLUSTER1_NAME..."
kubectl apply --context="${CLUSTER1_CTX}" -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml

echo "install metallb on $CLUSTER2_NAME..."
kubectl apply --context="${CLUSTER2_CTX}" -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml

#create metallb pool and L2 advertisment
echo "creating metallb l2 pool on $CLUSTER1_NAME..."
kubectl apply --context="${CLUSTER1_CTX}" -f - <<EOF
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.111-172.18.255.119
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: all-pools
  namespace: metallb-system
EOF

echo "creating metallb l2 pool on $CLUSTER2_NAME..."
kubectl apply --context="${CLUSTER2_CTX}" -f - <<EOF
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.121-172.18.255.129
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: all-pools
  namespace: metallb-system
EOF

