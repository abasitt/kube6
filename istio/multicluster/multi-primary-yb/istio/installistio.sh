#!/bin/bash

source ../../config.sh

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
# IMPORTANT: demo certs are used here and are public on github, please use your own certs in production
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
kubectl --context="${CLUSTER1_CTX}" label namespace istio-system topology.istio.io/network=${CLUSTER1_CTX}-net --overwrite

# Replace the placeholder CLUSTER_CTX with the clustre1 context in the iop.yaml file
# and install Istio using the modified configuration
sed -e "s/CLUSTER_CTX/${CLUSTER1_CTX}/g" iop.yaml | istioctl --context="${CLUSTER1_CTX}" install -f - --skip-confirmation

echo "expose services in $CLUSTER1_NAME..."
kubectl --context="${CLUSTER1_CTX}" apply -n istio-system -f expose-mc-svcs.yaml

# Install istio profile on cluster2
echo "Installing istio in $CLUSTER2_NAME..."
kubectl --context="${CLUSTER2_CTX}" label namespace istio-system topology.istio.io/network=${CLUSTER2_CTX}-net --overwrite

# Replace the placeholder CLUSTER_CTX with the clustre2 context in the iop.yaml file
# and install Istio using the modified configuration
sed -e "s/CLUSTER_CTX/${CLUSTER2_CTX}/g" iop.yaml | istioctl --context="${CLUSTER2_CTX}" install -f - --skip-confirmation

echo "expose services in $CLUSTER2_NAME..."
kubectl --context="${CLUSTER2_CTX}" apply -n istio-system -f expose-mc-svcs.yaml

# Enable Endpoint Discovery
echo "Enable Endpoint Discovery..."
istioctl create-remote-secret \
    --context="${CLUSTER2_CTX}" \
    --name="${CLUSTER2_CTX}" \
    --server=https://clu2-control-plane:6443 | \
    kubectl apply -f - --context="${CLUSTER1_CTX}"

istioctl create-remote-secret \
    --context="${CLUSTER1_CTX}" \
    --name="${CLUSTER1_CTX}" \
    --server=https://clu1-control-plane:6443 | \
    kubectl apply -f - --context="${CLUSTER2_CTX}"
