#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

#multi-network clusters
CLUSTER1_NAME=caldual



CLUSTER1_CTX=kind-caldual


#istio version
HUB=gcr.io/istio-release
TAG=1.23.0-alpha.0