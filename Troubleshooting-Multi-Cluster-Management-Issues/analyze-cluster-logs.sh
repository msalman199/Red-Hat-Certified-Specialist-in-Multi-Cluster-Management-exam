#!/bin/bash

CLUSTER_NAME=${1:-cluster1}
echo "Analyzing logs for cluster: $CLUSTER_NAME"

echo "=== Cluster Status ==="
oc get managedcluster "$CLUSTER_NAME" -o yaml | grep -A 10 "conditions:"

echo "=== Error Analysis ==="
oc logs -n open-cluster-management-agent deployment/klusterlet-registration-agent --tail=200 2>/dev/null \
  | grep -i "error\|failed\|timeout" || echo "No matching error lines found"

echo "=== Certificate Status ==="
oc get secrets -n open-cluster-management-agent | grep -E "hub-kubeconfig|bootstrap"

echo "=== Network Connectivity Message ==="
oc get managedcluster "$CLUSTER_NAME" -o jsonpath='{.status.conditions[?(@.type=="ManagedClusterConditionAvailable")].message}'
echo ""
