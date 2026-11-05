#!/bin/bash

echo "Monitoring Health Demo Application Rollout"
echo "=========================================="

while true; do
    echo ""
    echo "$(date): Checking rollout status..."
    
    # Check rollout status
    echo "Rollout Status:"
    oc get rollout health-demo-rollout -n health-demo -o custom-columns=NAME:.metadata.name,DESIRED:.spec.replicas,CURRENT:.status.replicas,UP-TO-DATE:.status.updatedReplicas,AVAILABLE:.status.availableReplicas
    
    # Check pod status
    echo ""
    echo "Pod Status:"
    oc get pods -n health-demo -l app=health-demo
    
    # Check service endpoints
    echo ""
    echo "Service Endpoints:"
    oc get endpoints -n health-demo
    
    # Check application health
    echo ""
    echo "Application Health Check:"
    if oc port-forward -n health-demo svc/health-demo-service 8081:80 >/dev/null 2>&1 &
    then
        PF_PID=$!
        sleep 2
        if curl -s http://localhost:8081/health >/dev/null 2>&1; then
            echo "✓ Application is healthy"
        else
            echo "✗ Application health check failed"
        fi
        kill $PF_PID 2>/dev/null
    fi
    
    echo ""
    echo "Press Ctrl+C to stop monitoring"
    sleep 30
done
