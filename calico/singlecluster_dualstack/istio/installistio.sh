#!/bin/bash

. ../config.sh

# download istio images to a host
echo "Pulling istio images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG

echo "load istio images to the clusters..."
kind load docker-image --name $CLUSTER1_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER1_NAME $HUB/proxyv2:$TAG

kind load docker-image --name $CLUSTER2_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER2_NAME $HUB/proxyv2:$TAG

# point this to your latest build binary
istioctl_latest=/usr/local/bin/istioctl

# install certs in both clusters
kubectl create namespace istio-system --context=${CLUSTER1_CTX}
kubectl create secret generic cacerts -n istio-system \
      --from-file=certs/cluster1/ca-cert.pem \
      --from-file=certs/cluster1/ca-key.pem \
      --from-file=certs/cluster1/root-cert.pem \
      --from-file=certs/cluster1/cert-chain.pem \
      --context=${CLUSTER1_CTX}

kubectl create namespace istio-system --context=${CLUSTER2_CTX}
kubectl create secret generic cacerts -n istio-system \
      --from-file=certs/cluster2/ca-cert.pem \
      --from-file=certs/cluster2/ca-key.pem \
      --from-file=certs/cluster2/root-cert.pem \
      --from-file=certs/cluster2/cert-chain.pem \
      --context=${CLUSTER2_CTX}

# Install istio iop profile on cluster1
echo "Installing istio in $CLUSTER1_NAME..."
istioctl --context="${CLUSTER1_CTX}" install -f iop-clu1.yaml --skip-confirmation

# Install istio profile on cluster2
echo "Installing istio in $CLUSTER2_NAME..."
istioctl --context="${CLUSTER2_CTX}" install -f iop-clu2.yaml --skip-confirmation


# Enable Endpoint Discovery
#echo "Enable Endpoint Discovery..."
#istioctl x create-remote-secret \
#    --context="${CLUSTER2_CTX}" \
#    --name=cluster2 \
#    --server=https://clu2-control-plane:6443 | \
#    kubectl apply -f - --context="${CLUSTER1_CTX}"
#
#istioctl x create-remote-secret \
#    --context="${CLUSTER1_CTX}" \
#    --name=cluster1 \
#    --server=https://clu1-control-plane:6443 | \
#    kubectl apply -f - --context="${CLUSTER2_CTX}"
#