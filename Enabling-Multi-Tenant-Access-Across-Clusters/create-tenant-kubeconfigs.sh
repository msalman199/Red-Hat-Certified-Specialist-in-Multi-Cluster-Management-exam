#!/bin/bash

# Get cluster information
CLUSTER_A_SERVER=$(kubectl config view -o jsonpath='{.clusters[?(@.name=="cluster-a")].cluster.server}')
CLUSTER_B_SERVER=$(kubectl config view -o jsonpath='{.clusters[?(@.name=="cluster-b")].cluster.server}')

# Create kubeconfig for tenant-alpha
cat > alpha-kubeconfig.yaml << EOL
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: $CLUSTER_A_SERVER
    insecure-skip-tls-verify: true
  name: cluster-a
- cluster:
    server: $CLUSTER_B_SERVER
    insecure-skip-tls-verify: true
  name: cluster-b
contexts:
- context:
    cluster: cluster-a
    namespace: tenant-alpha
    user: alpha-user
  name: alpha-cluster-a
- context:
    cluster: cluster-b
    namespace: tenant-alpha
    user: alpha-user
  name: alpha-cluster-b
current-context: alpha-cluster-a
users:
- name: alpha-user
  user:
    token: $(cat alpha-token-cluster-a.txt)
EOL

# Create kubeconfig for tenant-beta
cat > beta-kubeconfig.yaml << EOL
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: $CLUSTER_A_SERVER
    insecure-skip-tls-verify: true
  name: cluster-a
- cluster:
    server: $CLUSTER_B_SERVER
    insecure-skip-tls-verify: true
  name: cluster-b
contexts:
- context:
    cluster: cluster-a
    namespace: tenant-beta
    user: beta-user
  name: beta-cluster-a
- context:
    cluster: cluster-b
    namespace: tenant-beta
    user: beta-user
  name: beta-cluster-b
current-context: beta-cluster-a
users:
- name: beta-user
  user:
    token: $(cat beta-token-cluster-a.txt)
EOL

echo "Tenant kubeconfig files created successfully!"
