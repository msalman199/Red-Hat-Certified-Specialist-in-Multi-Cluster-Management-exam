#!/bin/bash

echo "=== RHACM Metrics Collection ==="

PROMETHEUS_ROUTE=$(oc get route -n open-cluster-management-observability prometheus -o jsonpath='{.spec.host}' 2>/dev/null)

if [ -n "$PROMETHEUS_ROUTE" ]; then
    echo "Prometheus endpoint: https://$PROMETHEUS_ROUTE"
    TOKEN=$(oc whoami -t)

    echo "=== Cluster Health Metrics ==="
    curl -sk -H "Authorization: Bearer $TOKEN" \
        "https://$PROMETHEUS_ROUTE/api/v1/query?query=cluster:cpu_usage_cores:sum" | jq .

    echo "=== Managed Cluster Info Metric ==="
    curl -sk -H "Authorization: Bearer $TOKEN" \
        "https://$PROMETHEUS_ROUTE/api/v1/query?query=acm_managed_cluster_info" | jq .
else
    echo "Observability stack not available, falling back to basic cluster status..."
    oc get managedclusters -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].type,AVAILABLE:.status.conditions[0].status
fi
