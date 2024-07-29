#!/bin/bash

. ../config.sh

# download istio images to a host
echo "Pulling istio images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG

echo "load istio images to the clusters..."
kind load docker-image --name $CLUSTER1_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER1_NAME $HUB/proxyv2:$TAG


# point this to your latest build binary
istioctl_latest=/usr/local/bin/istioctl

# install certs in both clusters
kubectl create namespace istio-system --context=${CLUSTER1_CTX}

# Install istio iop profile on cluster1
echo "Installing istio in $CLUSTER1_NAME..."
istioctl --context="${CLUSTER1_CTX}" install -f iop-clu.yaml --skip-confirmation