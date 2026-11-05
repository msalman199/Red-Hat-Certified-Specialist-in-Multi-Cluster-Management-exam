#!/bin/bash

# Function to get service account token
get_sa_token() {
    local context=$1
    local namespace=$2
    local sa_name=$3
    
    kubectl config use-context $context
    
    # Get the secret name for the service account
    SECRET_NAME=$(kubectl get serviceaccount $sa_name -n $namespace -o jsonpath='{.secrets[0].name}')
    
    if [ -z "$SECRET_NAME" ]; then
        # For newer Kubernetes versions, create a token manually
        kubectl create token $sa_name -n $namespace --duration=24h
    else
        # For older versions, extract from secret
        kubectl get secret $SECRET_NAME -n $namespace -o jsonpath='{.data.token}' | base64 -d
    fi
}

echo "Extracting tokens for cluster-a..."
echo "Alpha user token (cluster-a):"
ALPHA_TOKEN_A=$(get_sa_token cluster-a tenant-alpha alpha-user)
echo $ALPHA_TOKEN_A > alpha-token-cluster-a.txt

echo "Beta user token (cluster-a):"
BETA_TOKEN_A=$(get_sa_token cluster-a tenant-beta beta-user)
echo $BETA_TOKEN_A > beta-token-cluster-a.txt

echo "Extracting tokens for cluster-b..."
echo "Alpha user token (cluster-b):"
ALPHA_TOKEN_B=$(get_sa_token cluster-b tenant-alpha alpha-user)
echo $ALPHA_TOKEN_B > alpha-token-cluster-b.txt

echo "Beta user token (cluster-b):"
BETA_TOKEN_B=$(get_sa_token cluster-b tenant-beta beta-user)
echo $BETA_TOKEN_B > beta-token-cluster-b.txt

echo "Tokens extracted successfully!"
