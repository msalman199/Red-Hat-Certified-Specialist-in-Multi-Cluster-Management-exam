#!/bin/bash

echo "=== RHACM Troubleshooting Script ==="
echo "Date: $(date)"
echo ""

echo "=== Hub Cluster Status ==="
oc get multiclusterhub -n open-cluster-management
echo ""

echo "=== Managed Clusters Status ==="
oc get managedclusters
echo ""

echo "=== Non-Compliant Policies ==="
oc get policies --field-selector=status.compliant!=Compliant 2>/dev/null || echo "All policies are compliant"
echo ""

echo "=== Application Status ==="
oc get applications
oc get subscriptions
echo ""

echo "=== Recent Events ==="
oc get events --sort-by='.lastTimestamp' | tail -10
echo ""

echo "=== Resource Usage ==="
oc top nodes 2>/dev/null || echo "Metrics not available"
