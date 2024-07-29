#!/bin/bash

. ../config.sh

# Create CLUSTER1 cluster
echo "Creating cluster $CLUSTER1_NAME..."
kind create cluster --name $CLUSTER1_NAME --config cluster1.yaml

# Verify that the cluster is running
echo "Verifying cluster $CLUSTER1_NAME..."
kubectl cluster-info --context kind-$CLUSTER1_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER1_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done


# Load CNI images to both clusters
echo "Pulling calico images to a docker host..."
docker pull quay.io/tigera/operator:v1.34.0
docker pull quay.io/calico/typha:v3.28.0
docker pull quay.io/calico/node:v3.28.0
docker pull quay.io/calico/cni:v3.28.0
docker pull quay.io/calico/apiserver:v3.28.0
docker pull quay.io/calico/kube-controllers:v3.28.0
docker pull quay.io/calico/csi:v3.28.0

echo "load calico images to the clusters..."
kind load docker-image --name $CLUSTER1_NAME quay.io/tigera/operator:v1.34.0
kind load docker-image --name $CLUSTER1_NAME quay.io/calico/typha:v3.28.0
kind load docker-image --name $CLUSTER1_NAME quay.io/calico/node:v3.28.0
kind load docker-image --name $CLUSTER1_NAME quay.io/calico/cni:v3.28.0
kind load docker-image --name $CLUSTER1_NAME quay.io/calico/apiserver:v3.28.0
kind load docker-image --name $CLUSTER1_NAME quay.io/calico/kube-controllers:v3.28.0
kind load docker-image --name $CLUSTER1_NAME quay.io/calico/csi:v3.28.0

# apply calico cni kustomize
echo "install Calico CNI to clusters..."
kubectl --context kind-$CLUSTER1_NAME create -f calico/tigera-ns.yaml
#kubectl --context kind-$CLUSTER1_NAME apply -f calico/calico-k8sep.yaml
kubectl --context kind-$CLUSTER1_NAME create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f calico/operator-cr.yaml