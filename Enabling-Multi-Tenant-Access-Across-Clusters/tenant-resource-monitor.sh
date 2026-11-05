#!/bin/bash

echo "=== Multi-Tenant Resource Usage Report ==="
echo "Generated on: $(date)"
echo

monitor_cluster() {
    local cluster=$1
    echo "=== Resource Usage in $cluster ==="
    kubectl config use-context $cluster
    
    echo "Tenant Alpha Resources:"
    kubectl top pods -n tenant-alpha 2>/dev/null || echo "Metrics not available"
    kubectl get pods -n tenant-alpha -o wide
    
    echo
    echo "Tenant Beta Resources:"
    kubectl top pods -n tenant-beta 2>/dev/null || echo "Metrics not available"
    kubectl get pods -n tenant-beta -o wide
    
    echo
    echo "Shared Services Resources:"
    kubectl top pods -n shared-services 2>/dev/null || echo "Metrics not available"
    kubectl get pods -n shared-services -o wide
    
    echo "================================"
    echo
}

monitor_cluster cluster-a
monitor_cluster cluster-b

echo "Resource monitoring completed!"
