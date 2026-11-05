#!/bin/bash

CLUSTER_NAME=${1:-"all"}

check_cluster_health() {
    local cluster=$1
    echo "=== Health Check for Cluster: $cluster ==="

    echo "Cluster Info:"
    oc get managedcluster "$cluster" -o custom-columns=NAME:.metadata.name,VERSION:.status.version.kubernetes,AVAILABLE:.status.conditions[0].status

    echo "Cluster Conditions:"
    oc get managedcluster "$cluster" -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.message}{"\n"}{end}'

    echo "Addon Status:"
    oc get managedclusteraddons -n "$cluster"

    echo "Recent Non-Normal Events:"
    oc get events -n "$cluster" --sort-by='.lastTimestamp' --field-selector type!=Normal 2>/dev/null | tail -10
}

if [ "$CLUSTER_NAME" = "all" ]; then
    for cluster in $(oc get managedclusters -o name | cut -d'/' -f2); do
        check_cluster_health "$cluster"
        echo "----------------------------------------"
    done
else
    check_cluster_health "$CLUSTER_NAME"
fi
