#!/bin/bash

CLUSTER1_NAME=clu1
CLUSTER2_NAME=clu2

# Delete the cluster with name ambient
echo "Deleting $CLUSTER1_NAME..."
kind delete cluster --name $CLUSTER1_NAME

echo "Deleting $CLUSTER2_NAME..."
kind delete cluster --name $CLUSTER2_NAME

# Verify that the cluster is deleted
echo "Verifying cluster deletion..."
kind get clusters

