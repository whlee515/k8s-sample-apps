#!/bin/bash

# Prompt for User entry
read -p "Enter service account name [k8s-sa]: " SERVICE_ACCOUNT_NAME
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME:-k8s-sa}

# Update environment variables
CONTEXT=$(kubectl config current-context)
K8S_CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
NAMESPACE=default

#Create Service Account & Clusterrolebinding
echo -e "Creating Service Account \e[1;91m$SERVICE_ACCOUNT_NAME\e[0m and Clusterrolebinding..."
kubectl create sa $SERVICE_ACCOUNT_NAME
kubectl create clusterrolebinding $SERVICE_ACCOUNT_NAME --clusterrole=cluster-admin --serviceaccount=$NAMESPACE:$SERVICE_ACCOUNT_NAME
echo -e "Service Account and Clusterrolebinding \e[1;91m$SERVICE_ACCOUNT_NAME\e[0m created"
echo ""

#Obtain information to form Kubeconfig file
NEW_CONTEXT=$K8S_CLUSTER-$SERVICE_ACCOUNT_NAME
KUBECONFIG_FILE="$K8S_CLUSTER-$SERVICE_ACCOUNT_NAME"
FINAL_KUBECONFIG_FILE="$K8S_CLUSTER-$SERVICE_ACCOUNT_NAME.yml"

SECRET_NAME=$(kubectl get serviceaccount ${SERVICE_ACCOUNT_NAME} \
  --context ${CONTEXT} \
  --namespace ${NAMESPACE} \
  -o jsonpath='{.secrets[0].name}')
TOKEN_DATA=$(kubectl get secret ${SECRET_NAME} \
  --context ${CONTEXT} \
  --namespace ${NAMESPACE} \
  -o jsonpath='{.data.token}')

TOKEN=$(echo ${TOKEN_DATA} | base64 -d)

# Create dedicated kubeconfig
echo -e "Creating dedicated kubeconfig for \e[1;91m$SERVICE_ACCOUNT_NAME\e[0m..."
echo ""
# Create a full copy
kubectl config view --raw > ${KUBECONFIG_FILE}.full.tmp
# Switch working context to correct context
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp config use-context ${CONTEXT}

# Minify
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp \
  config view --flatten --minify > ${KUBECONFIG_FILE}.tmp

# Rename context
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  rename-context ${CONTEXT} ${NEW_CONTEXT}

# Create token user
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-credentials ${CONTEXT}-${NAMESPACE}-${SERVICE_ACCOUNT_NAME} \
  --token ${TOKEN}

# Set context to use token user
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-context ${NEW_CONTEXT} --user ${CONTEXT}-${NAMESPACE}-${SERVICE_ACCOUNT_NAME}

# Flatten/minify kubeconfig
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  view --flatten --minify > ${FINAL_KUBECONFIG_FILE}
echo ""

# Remove tmp
rm ${KUBECONFIG_FILE}.full.tmp
rm ${KUBECONFIG_FILE}.tmp
echo -e "Dedicated kubeconfig for \e[1;91m$SERVICE_ACCOUNT_NAME\033[0m created in \e[1;91m$K8S_CLUSTER\033[0m, filename \e[1;91m${FINAL_KUBECONFIG_FILE}\033[0m"
