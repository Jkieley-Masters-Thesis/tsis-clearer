#!/bin/bash

echo '127.0.0.1 jamesk-kubernetes-master' >>/etc/hosts
ssh -f -N asu-master

export KUBECONFIG=/app/config/asu-on-prem-config
kubectl delete jobs --all

if [[ -n "${CLOUD_ALSO}" ]]; then
  aws configure set default.region us-west-2
  aws configure set aws_access_key_id $AWS_KEY
  aws configure set aws_secret_access_key $AWS_ACCESS_KEY

  aws s3 cp s3://thesis-cluster-creation/id_rsa /app/id_rsa
  aws s3 cp s3://thesis-cluster-creation/id_rsa.pub /app/id_rsa.pub
  aws s3 cp s3://thesis-cluster-creation/kube_config /app/kube_config
  aws s3 cp s3://thesis-cluster-creation/ip-address.txt /app/ip-address.txt

  export KUBECONFIG=/app/kube_config
  kubectl delete jobs --all
fi


