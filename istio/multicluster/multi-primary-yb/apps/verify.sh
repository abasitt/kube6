#!/bin/bash

. ../../config.sh

echo "$CLUSTER1_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER1_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "$CLUSTER2_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER2_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "*************************"

echo "$CLUSTER1_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER1_CTX}"
echo "$CLUSTER2_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER2_CTX}"

echo "*************************"

#load helloworld and sleep images
echo "Curl from cluster $CLUSTER1_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER1_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done
#load helloworld and sleep images
echo "Curl from cluster $CLUSTER2_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER2_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done