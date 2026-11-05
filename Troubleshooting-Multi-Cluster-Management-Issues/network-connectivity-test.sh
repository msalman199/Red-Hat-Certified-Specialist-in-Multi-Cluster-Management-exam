#!/bin/bash

CLUSTER_NAME=${1:-cluster1}

echo "=== Network Connectivity Test for $CLUSTER_NAME ==="

CLUSTER_ENDPOINT=$(oc get managedcluster "$CLUSTER_NAME" -o jsonpath='{.spec.managedClusterClientConfigs[0].url}')
echo "Cluster endpoint: $CLUSTER_ENDPOINT"

if [ -n "$CLUSTER_ENDPOINT" ]; then
    curl -k --connect-timeout 10 "$CLUSTER_ENDPOINT/healthz" || echo "Endpoint not reachable"
fi

echo "Klusterlet Status:"
oc get klusterlet -A 2>/dev/null || echo "No klusterlet found"

echo "Agent Pod Status:"
oc get pods -n open-cluster-management-agent --selector=app=klusterlet-registration-agent
oc get pods -n open-cluster-management-agent --selector=app=klusterlet-work-agent

echo "Certificate Status:"
oc get secrets -n open-cluster-management-agent | grep -E "bootstrap|hub-kubeconfig"

echo "Cluster Lease Status:"
oc get lease -n open-cluster-management-agent "cluster-lease-$CLUSTER_NAME" 2>/dev/null || echo "No lease found with that name (check exact lease naming in your environment)"
