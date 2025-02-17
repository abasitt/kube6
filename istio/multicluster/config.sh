#! /bin/bash
# This script is used to set up the environment for Istio multi-cluster demo

export CLUSTER1_NAME=clu1
export CLUSTER2_NAME=clu2

export CLUSTER1_CTX=kind-clu1
export CLUSTER2_CTX=kind-clu2

#istio version
export HUB=gcr.io/istio-release
export TAG=1.24.3