#!/bin/bash

CLUSTER_NAME=${1:-cluster1}

echo "=== Resource Monitoring for $CLUSTER_NAME ==="

echo "Cluster Node Resource Usage:"
oc adm top nodes --selector=cluster.open-cluster-management.io/clustername="$CLUSTER_NAME" 2>/dev/null || echo "Metrics not available"

echo "RHACM Component Resource Usage:"
oc adm top pods -n open-cluster-management --sort-by=cpu 2>/dev/null || echo "Metrics not available"
oc adm top pods -n open-cluster-management-agent --sort-by=cpu 2>/dev/null || echo "Metrics not available"

echo "Evicted Pods (any namespace):"
oc get pods -A --field-selector status.phase=Failed 2>/dev/null | grep Evicted || echo "No evicted pods found"

echo "Pending Pods due to scheduling failures:"
oc get events -n open-cluster-management --field-selector reason=FailedScheduling 2>/dev/null || echo "No FailedScheduling events found"
