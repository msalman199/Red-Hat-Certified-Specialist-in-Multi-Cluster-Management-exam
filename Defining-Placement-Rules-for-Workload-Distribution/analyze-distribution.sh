#!/bin/bash

echo "=== Workload Distribution Analysis ==="
echo ""

NAMESPACES=("placement-demo")

for ns in "${NAMESPACES[@]}"; do
    echo "Analyzing namespace: $ns"
    echo "------------------------"
    
    # Get all deployments in the namespace
    deployments=$(oc get deployments -n $ns --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null)
    
    if [ -z "$deployments" ]; then
        echo "No deployments found in namespace $ns"
        continue
    fi
    
    for deployment in $deployments; do
        echo "Deployment: $deployment"
        
        # Check deployment on each cluster
        for cluster in $(oc get managedclusters --no-headers -o custom-columns=NAME:.metadata.name); do
            replica_count=$(oc --context=$cluster get deployment $deployment -n $ns -o jsonpath='{.status.replicas}' 2>/dev/null || echo "0")
            ready_count=$(oc --context=$cluster get deployment $deployment -n $ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
            echo "  $cluster: $ready_count/$replica_count replicas ready"
        done
        echo ""
    done
done
