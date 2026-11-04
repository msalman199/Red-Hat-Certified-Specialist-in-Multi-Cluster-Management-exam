#!/bin/bash

echo "=== Final Compliance Verification ==="
echo ""

echo "1. Checking all policies are compliant..."
POLICIES=$(oc get policy -n policy-automation -o jsonpath='{.items[*].metadata.name}')
for policy in $POLICIES; do
  STATUS=$(oc get policy $policy -n policy-automation -o jsonpath='{.status.compliant}')
  echo "Policy: $policy - Status: $STATUS"
done
echo ""

echo "2. Verifying managed cluster connectivity..."
oc get managedcluster -o custom-columns=NAME:.metadata.name,AVAILABLE:.status.conditions[1].status
echo ""

echo "3. Checking policy enforcement on managed clusters..."
for cluster in cluster1 cluster2; do
  echo "--- Cluster: $cluster ---"
  oc config use-context $cluster 2>/dev/null
  echo "ResourceQuotas:"
  oc get resourcequota -n policy-test --no-headers 2>/dev/null | wc -l
  echo "LimitRanges:"
  oc get limitrange -n policy-test --no-headers 2>/dev/null | wc -l
  echo "NetworkPolicies:"
  oc get networkpolicy -n policy-test --no-headers 2>/dev/null | wc -l
  echo "Privileged Pods:"
  oc get pods -n policy-test -o jsonpath='{.items[?(@.spec.containers[*].securityContext.privileged==true)].metadata.name}' 2>/dev/null
  echo ""
done

oc config use-context hub
echo "Verification complete!"
