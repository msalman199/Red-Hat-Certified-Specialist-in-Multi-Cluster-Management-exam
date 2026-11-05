#!/bin/bash

echo "=== Placement Rule Monitoring Dashboard ==="
echo "Date: $(date)"
echo ""

echo "1. Active Placement Rules:"
oc get placementrule -A --no-headers | wc -l
echo ""

echo "2. Placement Rules by Namespace:"
oc get placementrule -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,CLUSTERS:.status.numberOfSelectedClusters
echo ""

echo "3. Cluster Selection Summary:"
for cluster in $(oc get managedclusters --no-headers -o custom-columns=NAME:.metadata.name); do
    echo "Cluster: $cluster"
    echo "  Labels: $(oc get managedcluster $cluster -o jsonpath='{.metadata.labels}' | tr ',' '\n' | grep -v '^{' | grep -v '^}' | head -3)"
    echo "  Status: $(oc get managedcluster $cluster -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterConditionAvailable")].status}')"
    echo ""
done

echo "4. Recent Placement Decisions:"
oc get placementdecision -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,CLUSTERS:.status.decisions[*].clusterName
