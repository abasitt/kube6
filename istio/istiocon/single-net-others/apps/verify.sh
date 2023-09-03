#!/bin/bash

. ../../config.sh

echo "$CLUSTER5_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER5_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "$CLUSTER6_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER6_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "*************************"

echo "$CLUSTER5_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER5_CTX}"
echo "$CLUSTER6_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER6_CTX}"

echo "*************************"

#load helloworld and sleep images
echo "Curl from cluster $CLUSTER5_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER5_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done
#load helloworld and sleep images
echo "Curl from cluster $CLUSTER6_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER6_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done