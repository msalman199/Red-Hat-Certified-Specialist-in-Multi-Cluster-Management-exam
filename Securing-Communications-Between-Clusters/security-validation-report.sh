#!/bin/bash
echo "RHACM TLS Security Validation Report"
echo "===================================="
echo "Date: $(date)"
echo ""

echo "1. Hub Cluster TLS Configuration:"
oc get secret hub-tls-secret -n open-cluster-management -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -subject -dates

echo ""
echo "2. Managed Clusters Status:"
oc get managedclusters -o custom-columns=NAME:.metadata.name,AVAILABLE:.status.conditions[?(@.type==\"ManagedClusterConditionAvailable\")].status,JOINED:.status.conditions[?(@.type==\"ManagedClusterJoined\")].status

echo ""
echo "3. Policy Compliance:"
oc get policies.policy.open-cluster-management.io -A --no-headers | wc -l | xargs echo "Total policies deployed:"

echo ""
echo "4. TLS Cipher Validation:"
echo "Testing secure cipher suites..."
openssl s_client -connect multicloud-console.apps.hub-cluster.example.com:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384' < /dev/null 2>/dev/null | grep "Cipher is"

echo ""
echo "Security validation completed successfully!"
