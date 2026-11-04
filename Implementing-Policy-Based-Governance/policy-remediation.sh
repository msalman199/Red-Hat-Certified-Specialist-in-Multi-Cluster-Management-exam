#!/bin/bash

# Policy Remediation Script
echo "=== Policy Remediation Tool ==="
echo "This tool will help fix common policy violations"
echo

fix_deployment_security() {
    local namespace=$1
    local deployment=$2

    echo "Fixing security context for deployment $namespace/$deployment"

    cat > security-patch.yaml << PATCH_EOF
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      containers:
      - name: nginx
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
PATCH_EOF

    kubectl patch deployment $deployment -n $namespace --patch-file security-patch.yaml
    rm security-patch.yaml
}

fix_deployment_resources() {
    local namespace=$1
    local deployment=$2

    echo "Adding resource limits to deployment $namespace/$deployment"

    cat > resource-patch.yaml << PATCH_EOF
spec:
  template:
    spec:
      containers:
      - name: nginx
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
PATCH_EOF

    kubectl patch deployment $deployment -n $namespace --patch-file resource-patch.yaml
    rm resource-patch.yaml
}

echo "Scanning for deployments that need remediation..."

kubectl get deployments --all-namespaces -o json | jq -r '.items[] | "\(.metadata.namespace) \(.metadata.name)"' | while read namespace deployment; do
    echo "Checking deployment: $namespace/$deployment"

    has_security_context=$(kubectl get deployment $deployment -n $namespace -o jsonpath='{.spec.template.spec.securityContext}' 2>/dev/null)
    if [ -z "$has_security_context" ]; then
        echo "  Missing security context"
        read -p "  Fix security context for $namespace/$deployment? (y/n): " fix_security
        if [ "$fix_security" = "y" ]; then
            fix_deployment_security $namespace $deployment
        fi
    fi

    has_resources=$(kubectl get deployment $deployment -n $namespace -o jsonpath='{.spec.template.spec.containers[0].resources.limits}' 2>/dev/null)
    if [ -z "$has_resources" ]; then
        echo "  Missing resource limits"
        read -p "  Fix resource limits for $namespace/$deployment? (y/n): " fix_resources
        if [ "$fix_resources" = "y" ]; then
            fix_deployment_resources $namespace $deployment
        fi
    fi
done

echo "Remediation complete!"
