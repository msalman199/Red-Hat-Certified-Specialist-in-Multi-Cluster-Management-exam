#!/bin/bash

echo "Starting continuous compliance monitoring..."
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
  clear
  echo "=== RHACM Policy Compliance Dashboard ==="
  echo "Timestamp: $(date)"
  echo ""
  
  echo "=== Policy Overview ==="
  oc get policy -n policy-automation -o custom-columns=NAME:.metadata.name,COMPLIANT:.status.compliant,REMEDIATION:.spec.remediationAction,DISABLED:.spec.disabled
  echo ""
  
  echo "=== Cluster Status ==="
  oc get managedcluster -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].status,AVAILABLE:.status.conditions[1].status
  echo ""
  
  echo "=== Recent Policy Events ==="
  oc get events -n policy-automation --sort-by='.lastTimestamp' | tail -5
  echo ""
  
  echo "Refreshing in 30 seconds..."
  sleep 30
done
