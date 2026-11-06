#!/bin/bash

echo "=== Multi-Cluster Health Monitor ==="
echo "Date: $(date)"
echo ""

echo "=== Managed Clusters Status ==="
oc get managedclusters -o custom-columns=NAME:.metadata.name,AVAILABLE:.status.conditions[?(@.type==\"ManagedClusterConditionAvailable\")].status,JOINED:.status.conditions[?(@.type==\"ManagedClusterJoined\")].status
echo ""

echo "=== Policy Compliance Status ==="
oc get policies -o custom-columns=NAME:.metadata.name,COMPLIANT:.status.compliant
echo ""

echo "=== Cluster Resource Usage ==="
for cluster in managed-cluster-1 managed-cluster-2; do
    echo "Cluster: $cluster"
    oc get managedclusterinfo $cluster -n $cluster -o jsonpath='{.status.nodeList[*].capacity}' 2>/dev/null || echo "  Info not available"
    echo ""
done
