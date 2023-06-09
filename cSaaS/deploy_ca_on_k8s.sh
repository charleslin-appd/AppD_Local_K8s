#!/bin/bash
###############################################################################
# This script will deploy AppD Cluster Agent Operater and Collectors to the 
# current profile. 
# 
# Ensure the following environment vaiables are set properly before running
# APPD_CSAAS_USERNAME
# APPD_CSAAS_PASSWORD
# APPD_CSAAS_ACCESS_KEY
# APPD_CSAAS_GLOBAL_ACCOUNT
#
###############################################################################
if [[ -z ${APPD_CSAAS_USERNAME+x} ]]; then
    echo "APPD_CSAAS_USERNAME is not set" && exit 1
elif [[ -z ${APPD_CSAAS_PASSWORD+x} ]]; then
    echo "APPD_CSAAS_PASSWORD is not set" && exit 1
elif [[ -z ${APPD_CSAAS_ACCESS_KEY+x} ]]; then
    echo "APPD_CSAAS_ACCESS_KEY is not set" && exit 1
elif [[ -z ${APPD_CSAAS_GLOBAL_ACCOUNT+x} ]]; then
    echo "APPD_CSAAS_GLOBAL_ACCOUNT is not set" && exit 1
fi
set -x #echo on
cd "$(dirname "$0")"
kubectl create namespace appdynamics
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server --namespace=appdynamics \ 
--set args={"--kubelet-insecure-tls=true"} 
helm repo add appdynamics-charts https://ciscodevnet.github.io/appdynamics-charts
# Update to the latest chart
helm repo update 
helm install $USER-ca appdynamics-charts/cluster-agent --namespace=appdynamics \
-f values-ca1.yaml \
--set controllerInfo.username=$APPD_CSAAS_USERNAME \
--set controllerInfo.password=$APPD_CSAAS_PASSWORD \
--set controllerInfo.accessKey=$APPD_CSAAS_ACCESS_KEY \
--set controllerInfo.globalAccount=$APPD_CSAAS_GLOBAL_ACCOUNT
sleep 10
kubectl -n appdynamics get all
say -v "Samantha" "Appdynamics cluster agent deployment completed"
