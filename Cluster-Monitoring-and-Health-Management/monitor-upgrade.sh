#!/bin/bash

echo "Monitoring cluster upgrade progress..."
echo "======================================"

while true; do
    echo "$(date): Checking upgrade status..."
    
    # Check hub cluster policy status
    echo "Policy Status:"
    oc get policy cluster-upgrade-policy -o jsonpath='{.status.compliant}' 2>/dev/null || echo "Policy not found"
    
    # Check managed cluster version
    echo "Managed Cluster Version:"
    oc --context=cluster1 get clusterversion version -o jsonpath='{.status.desired.version}' 2>/dev/null || echo "Cannot connect to managed cluster"
    
    # Check upgrade progress
    echo "Upgrade Progress:"
    oc --context=cluster1 get clusterversion version -o jsonpath='{.status.conditions[?(@.type=="Progressing")].message}' 2>/dev/null || echo "No progress info"
    
    echo "------------------------"
    sleep 60
done
