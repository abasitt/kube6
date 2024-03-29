#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

#multi-network clusters
CLUSTER1_NAME=clu1
CLUSTER2_NAME=clu2
CLUSTER3_NAME=clu3
CLUSTER4_NAME=clu4
CLUSTER5_NAME=clu5
CLUSTER6_NAME=clu6

CLUSTER1_CTX=kind-clu1
CLUSTER2_CTX=kind-clu2
CLUSTER3_CTX=kind-clu3
CLUSTER4_CTX=kind-clu4
CLUSTER5_CTX=kind-clu5
CLUSTER6_CTX=kind-clu6
CTX_CLUSTER1=kind-clu1
CTX_CLUSTER2=kind-clu2

#istio version
HUB=docker.io/istio
TAG=1.18.2