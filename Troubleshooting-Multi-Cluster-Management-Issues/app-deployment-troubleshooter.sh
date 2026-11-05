#!/bin/bash

APP_NAME=${1:-"sample-app"}
NAMESPACE=${2:-"default"}

echo "=== Application Deployment Troubleshooter ==="
echo "Application: $APP_NAME"
echo "Namespace: $NAMESPACE"

echo "=== Application Status ==="
oc get application "$APP_NAME" -n "$NAMESPACE" -o yaml 2>/dev/null || echo "Application not found"

echo "=== Subscription Status ==="
SUBSCRIPTIONS=$(oc get subscription -n "$NAMESPACE" -l app="$APP_NAME" --no-headers 2>/dev/null)
if [ -n "$SUBSCRIPTIONS" ]; then
    oc get subscription -n "$NAMESPACE" -l app="$APP_NAME" -o custom-columns=NAME:.metadata.name,PHASE:.status.phase,MESSAGE:.status.message
else
    echo "No subscriptions found for application $APP_NAME"
fi

echo "=== Placement Rules ==="
oc get placementrule -n "$NAMESPACE" -l app="$APP_NAME" -o custom-columns=NAME:.metadata.name,SATISFIED:.status.satisfied 2>/dev/null

echo "=== Placement Decisions ==="
oc get placementdecision -n "$NAMESPACE" -l app="$APP_NAME" 2>/dev/null

echo "=== Deployed Resources on Target Clusters ==="
for cluster in $(oc get managedclusters -o name | cut -d'/' -f2); do
    echo "Checking cluster: $cluster"
    oc get manifestwork -n "$cluster" 2>/dev/null | grep "$APP_NAME" || echo "No manifestwork found on $cluster"
done

echo "=== Common Issues Check ==="
echo "1. Image pull / mount errors:"
oc get events -n "$NAMESPACE" --field-selector reason=Failed 2>/dev/null | grep -i "image\|pull" || echo "None found"

echo "2. Scheduling failures:"
oc get events -n "$NAMESPACE" --field-selector reason=FailedScheduling 2>/dev/null || echo "None found"

echo "3. RBAC issues:"
oc get events -n "$NAMESPACE" --field-selector reason=FailedCreate 2>/dev/null | grep -i "forbidden\|unauthorized" || echo "None found"
