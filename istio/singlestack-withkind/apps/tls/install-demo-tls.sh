#!/bin/bash
. ../../config.sh

CLUSTER_NAME=ipv4

# Run the bash script with the directory as an argument
#./create-cert.sh "$DIR"
./create-cert.sh


# load tcp echo images to kind
echo "Pulling images to a docker host..."
docker pull nginx:1.25.1-alpine
docker pull curlimages/curl

echo "Load images to kind clusters..."
kind load docker-image --name $CLUSTER_NAME nginx:1.25.1-alpine
kind load docker-image --name $CLUSTER_NAME curlimages/curl

echo "Install demo apps to kind clusters..."
kubectl create secret tls nginx-example-tls --key "/tmp/nginx.key" --cert "/tmp/nginx.crt"
kubectl --context="${CLUSTER_CTX}" label ns default istio-injection=enabled --overwrite
kubectl create configmap nginx-conf --from-file=nginx.conf
kubectl --context="${CLUSTER_CTX}" apply -f nginx.yaml

# for testing tls use
# openssl s_client -connect server:port
# example logs [2023-08-03T04:52:16.359Z] "- - -" 0 - - - "-" 439 1925 60036 - "-" "-" "-" "-" "10.244.2.7:4335" inbound|4335|| 127.0.0.6:51141 10.244.2.7:4335 172.18.0.4:33167 - -