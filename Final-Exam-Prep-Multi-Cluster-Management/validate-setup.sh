#!/bin/bash

echo "=== Multi-Cluster Setup Validation ==="
echo "Date: $(date)"
echo ""

# Function to check if resource exists
check_resource() {
    local resource_type=$1
    local resource_name=$2
    local namespace=${3:-"default"}
    
    if oc get $resource_type $resource_name -n $namespace &>/dev/null; then
        echo "✓ $resource_type/$resource_name exists in namespace $namespace"
        return 0
    else
        echo "✗ $resource_type/$resource_name NOT found in namespace $namespace"
        return 1
    fi
}

echo "=== Checking Managed Clusters ==="
check_resource managedcluster managed-cluster-1
check_resource managedcluster managed-cluster-2
echo ""

echo "=== Checking Policies ==="
check_resource policy policy-namespace
check_resource policy policy-networkpolicy
check_resource policy policy-resourcequota
echo ""

echo "=== Checking Applications ==="
check_resource application sample-web-app
check_resource subscription sample-app-subscription
check_resource placementrule sample-app-placement
echo ""

echo "=== Checking Policy Compliance ==="
for policy in policy-namespace policy-networkpolicy policy-resourcequota; do
    compliance=$(oc get policy $policy -o jsonpath='{.status.compliant}' 2>/dev/null)
    if [ "$compliance" = "Compliant" ]; then
        echo "✓ $policy is compliant"
    else
        echo "✗ $policy is not compliant (status: $compliance)"
    fi
done
echo ""

echo "=== Checking Cluster Conditions ==="
for cluster in managed-cluster-1 managed-cluster-2; do
    available=$(oc get managedcluster $cluster -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterConditionAvailable")].status}' 2>/dev/null)
    joined=$(oc get managedcluster $cluster -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterJoined")].status}' 2>/dev/null)
    
    if [ "$available" = "True" ] && [ "$joined" = "True" ]; then
        echo "✓ $cluster is available and joined"
    else
        echo "✗ $cluster status - Available: $available, Joined: $joined"
    fi
done

echo ""
echo "=== Validation Complete ==="
