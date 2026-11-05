#!/bin/bash

echo "Multi-Cluster Application Health Monitor"
echo "========================================"

for app in $(kubectl get applications -n argocd -o jsonpath='{.items[*].metadata.name}'); do
    echo "Application: $app"
    
    # Get sync status
    sync_status=$(kubectl get application $app -n argocd -o jsonpath='{.status.sync.status}')
    echo "  Sync Status: $sync_status"
    
    # Get health status
    health_status=$(kubectl get application $app -n argocd -o jsonpath='{.status.health.status}')
    echo "  Health Status: $health_status"
    
    # Get last sync time
    last_sync=$(kubectl get application $app -n argocd -o jsonpath='{.status.operationState.finishedAt}')
    echo "  Last Sync: $last_sync"
    
    echo "  ---"
done
