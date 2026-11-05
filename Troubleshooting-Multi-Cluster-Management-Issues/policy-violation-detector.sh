#!/bin/bash

echo "=== Policy Violation Detector ==="

echo "=== Policy Compliance Overview ==="
oc get policy -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,COMPLIANCE:.status.compliant 2>/dev/null

echo "=== Non-Compliant Policies ==="
NON_COMPLIANT=$(oc get policy -A --no-headers 2>/dev/null | grep -v "Compliant$")
if [ -n "$NON_COMPLIANT" ]; then
    echo "$NON_COMPLIANT"
else
    echo "All policies report Compliant (re-run after applying the sample policy below)"
fi

echo "=== Configuration Policy Templates ==="
oc get configurationpolicy -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,COMPLIANCE:.status.compliant 2>/dev/null

echo "=== Placement Bindings ==="
oc get placementbinding -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,POLICY:.subjects[0].name,PLACEMENT:.placementRef.name 2>/dev/null

echo "=== Recent Policy Events ==="
oc get events -A --field-selector reason=PolicyStatusSync 2>/dev/null --sort-by='.lastTimestamp' | tail -10
