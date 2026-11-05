#!/bin/bash

POLICY_NAME=${1:-"security-policy"}
NAMESPACE=${2:-"default"}

echo "=== Policy Violation Resolver ==="
echo "Policy: $POLICY_NAME"
echo "Namespace: $NAMESPACE"

echo "=== Policy Details ==="
oc get policy "$POLICY_NAME" -n "$NAMESPACE" -o yaml | grep -A 20 "status:"

analyze_violations() {
    echo "=== Violation Analysis ==="
    CONFIG_POLICIES=$(oc get configurationpolicy -A --no-headers 2>/dev/null | grep "$POLICY_NAME" | awk '{print $2}')
    for config_policy in $CONFIG_POLICIES; do
        echo "Analyzing configuration policy: $config_policy"
        oc get configurationpolicy "$config_policy" -n "$NAMESPACE" -o jsonpath='{.status.compliancyDetails[*].conditions[*].message}' 2>/dev/null | tr ' ' '\n'
    done
}

remediate_violations() {
    echo "=== Remediation Options ==="
    REMEDIATION_ACTION=$(oc get policy "$POLICY_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.remediationAction}')
    echo "Current remediation action: $REMEDIATION_ACTION"

    if [ "$REMEDIATION_ACTION" = "inform" ]; then
        echo "Policy is in inform mode. Removing the violating resource directly, since this policy type only informs:"
        oc delete pod privileged-test-pod -n "$NAMESPACE" --ignore-not-found=true
    fi

    echo "Remaining privileged pods (should be empty):"
    oc get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].securityContext.privileged}{"\n"}{end}' | grep true || echo "None found"
}

create_compliant_resources() {
    echo "=== Creating Compliant Alternative ==="
    cat > compliant-pod.yaml << 'EOYAML'
apiVersion: v1
kind: Pod
metadata:
  name: compliant-test-pod
  namespace: default
spec:
  containers:
  - name: test
    image: nginx
    securityContext:
      privileged: false
      runAsNonRoot: true
      runAsUser: 1000
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
EOYAML
    oc apply -f compliant-pod.yaml
    echo "Compliant pod applied: compliant-test-pod"
}

analyze_violations
remediate_violations
create_compliant_resources

echo "=== Final Policy Status (allow a few seconds for re-evaluation) ==="
sleep 15
oc get policy "$POLICY_NAME" -n "$NAMESPACE" -o custom-columns=NAME:.metadata.name,COMPLIANCE:.status.compliant
