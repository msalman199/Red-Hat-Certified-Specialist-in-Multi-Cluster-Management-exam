#!/bin/bash

echo "=== Failover Testing Script ==="
echo "Monitoring placement decisions every 30 seconds..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
    echo "$(date): Current placement decisions:"
    oc get placementdecision -n placement-demo -o custom-columns=NAME:.metadata.name,CLUSTERS:.status.decisions[*].clusterName
    echo ""
    
    echo "Cluster health status:"
    oc get managedclusters -o custom-columns=NAME:.metadata.name,AVAILABLE:.status.conditions[?(@.type==\"ManagedClusterConditionAvailable\")].status,JOINED:.status.conditions[?(@.type==\"ManagedClusterJoined\")].status
    echo "----------------------------------------"
    
    sleep 30
done
