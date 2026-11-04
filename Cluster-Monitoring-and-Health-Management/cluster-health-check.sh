#!/bin/bash

echo "RHACM Cluster Health Report"
echo "=========================="
echo "Generated: $(date)"
echo ""

# Check hub cluster health
echo "Hub Cluster Status:"
echo "-------------------"
oc get pods -n open-cluster-management | grep -v Running | wc -l | xargs echo "Non-running pods:"
oc get managedclusters --no-headers | wc -l | xargs echo "Total managed clusters:"

echo ""

# Check each managed cluster
echo "Managed Clusters Health:"
echo "------------------------"

for cluster in $(oc get managedclusters -o name | cut -d'/' -f2); do
    echo "Cluster: $cluster"
    
    # Check availability
    available=$(oc get managedcluster $cluster -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterConditionAvailable")].status}')
    echo "  Available: $available"
    
    # Check join status
    joined=$(oc get managedcluster $cluster -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterJoined")].status}')
    echo "  Joined: $joined"
    
    # Check version
    version=$(oc get managedcluster $cluster -o jsonpath='{.status.version.kubernetes}')
    echo "  Version: $version"
    
    # Check last heartbeat
    heartbeat=$(oc get managedcluster $cluster -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterConditionAvailable")].lastTransitionTime}')
    echo "  Last Heartbeat: $heartbeat"
    
    echo ""
done

# Check observability status
echo "Observability Status:"
echo "--------------------"
oc get pods -n open-cluster-management-observability | grep -v Running | wc -l | xargs echo "Non-running observability pods:"

# Check policy compliance
echo "Policy Compliance:"
echo "------------------"
oc get policies --all-namespaces --no-headers | wc -l | xargs echo "Total policies:"
oc get policies --all-namespaces -o jsonpath='{.items[?(@.status.compliant=="NonCompliant")].metadata.name}' | wc -w | xargs echo "Non-compliant policies:"

