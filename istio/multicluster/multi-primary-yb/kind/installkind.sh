#!/bin/bash

# Exit script if kind not installed
if ! command -v kind &> /dev/null
then
  echo "Kind not found, please install out of script..."
  exit 1
fi

CLUSTER1_NAME=clu1
CLUSTER2_NAME=clu2


# Create cluster1 cluster
echo "Creating cluster $CLUSTER1_NAME..."
kind create cluster --name $CLUSTER1_NAME --config cluster.yaml
# Add topology labels to nodes in cluster1
echo "Adding topology labels to nodes in cluster $CLUSTER1_NAME..."
kubectl label nodes --overwrite --all topology.kubernetes.io/region=us-west topology.kubernetes.io/zone=us-west1-a

# Create cluster2 cluster
echo "Creating cluster $CLUSTER2_NAME..."
kind create cluster --name $CLUSTER2_NAME --config cluster.yaml
# Add topology labels to nodes in cluster2
echo "Adding topology labels to nodes in cluster $CLUSTER2_NAME..."
kubectl label nodes --overwrite --all topology.kubernetes.io/region=us-east topology.kubernetes.io/zone=us-east1-a

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

# Verify that the cluster is running
echo "Verifying cluster $CLUSTER2_NAME..."
kubectl cluster-info --context kind-$CLUSTER2_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER2_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done
