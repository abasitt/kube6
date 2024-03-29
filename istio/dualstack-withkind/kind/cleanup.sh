#!/bin/bash

CLUSTER_NAME=ipv6singlestack

# Delete the cluster with name ambient
echo "Deleting cluster ambient..."
kind delete cluster --name $CLUSTER_NAME

# Verify that the cluster is deleted
echo "Verifying cluster deletion..."
kind get clusters

