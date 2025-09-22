#!/bin/bash
AWS_REGION="us-east-1"
CLUSTER_NAME="lncr-prd-eks"
SERVICE_NAME="lncr-app-service"
NAMESPACE="ns-lncr"
aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
export KUBECONFIG=/tmp/kubeconfig
DNS=$(kubectl get svc ${SERVICE_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "{\"nlb_dns_name\": \"$DNS\"}"