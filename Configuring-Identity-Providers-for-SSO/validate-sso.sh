#!/bin/bash

echo "=== SSO Validation Script ==="
echo "Testing authentication across clusters..."

# Test Cluster 1
echo "Testing Cluster 1..."
oc config use-context cluster1
CLUSTER1_API=$(oc whoami --show-server)
echo "Cluster 1 API: $CLUSTER1_API"

# Test authentication with testuser1
echo "Testing testuser1 authentication..."
oc login --username=testuser1 --password=RedHat123! > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ testuser1 authentication successful on Cluster 1"
    oc whoami
else
    echo "✗ testuser1 authentication failed on Cluster 1"
fi

# Test Cluster 2
echo "Testing Cluster 2..."
oc config use-context cluster2
CLUSTER2_API=$(oc whoami --show-server)
echo "Cluster 2 API: $CLUSTER2_API"

# Test authentication with testuser1
echo "Testing testuser1 authentication..."
oc login --username=testuser1 --password=RedHat123! > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ testuser1 authentication successful on Cluster 2"
    oc whoami
else
    echo "✗ testuser1 authentication failed on Cluster 2"
fi

echo "=== Validation Complete ==="
