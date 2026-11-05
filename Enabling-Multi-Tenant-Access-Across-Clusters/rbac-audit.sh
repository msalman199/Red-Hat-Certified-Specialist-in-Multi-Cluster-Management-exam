#!/bin/bash

echo "=== Multi-Tenant RBAC Audit Report ==="
echo "Generated on: $(date)"
echo

# Function to audit cluster
audit_cluster() {
    local cluster=$1
    echo "=== Auditing $cluster ==="
    kubectl config use-context $cluster
    
    echo "Namespaces:"
    kubectl get namespaces --show-labels | grep tenant
    
    echo
    echo "Service Accounts:"
    kubectl get serviceaccounts -A | grep -E "(alpha-user|beta-user|shared-admin)"
    
    echo
    echo "Roles:"
    kubectl get roles -A | grep -E "(tenant-alpha-role|tenant-beta-role|shared-services-reader)"
    
    echo
    echo "RoleBindings:"
    kubectl get rolebindings -A | grep -E "(tenant-alpha-binding|tenant-beta-binding|shared-services)"
    
    echo
    echo "ClusterRoleBindings:"
    kubectl get clusterrolebindings | grep service-discovery
    
    echo
    echo "Network Policies:"
    kubectl get networkpolicies -A
    
    echo
    echo "Running Pods by Tenant:"
    kubectl get pods -A -l tenant=alpha
    kubectl get pods -A -l tenant=beta
    kubectl get pods -A -l tenant=shared
    
    echo "================================"
    echo
}

# Audit both clusters
audit_cluster cluster-a
audit_cluster cluster-b

echo "=== Access Validation Tests ==="

# Test tenant access
export KUBECONFIG=alpha-kubeconfig.yaml
kubectl config use-context alpha-cluster-a
echo "Tenant Alpha can access their namespace: $(kubectl get pods -n tenant-alpha --no-headers | wc -l) pods"

export KUBECONFIG=beta-kubeconfig.yaml
kubectl config use-context beta-cluster-a
echo "Tenant Beta can access their namespace: $(kubectl get pods -n tenant-beta --no-headers | wc -l) pods"

unset KUBECONFIG
echo "Audit completed successfully!"
