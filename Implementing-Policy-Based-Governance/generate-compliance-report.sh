#!/bin/bash

# Comprehensive Compliance Report Generator
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="compliance-reports"
mkdir -p $REPORT_DIR

CLUSTERS=("cluster-1" "cluster-2")

for cluster in "${CLUSTERS[@]}"; do
    echo "Generating report for $cluster..."
    CLUSTER_REPORT="$REPORT_DIR/${cluster}-compliance-${TIMESTAMP}.html"

    kubectl config use-context $cluster

    # Collect data from the cluster before writing the HTML
    GATEKEEPER_PODS=$(kubectl get pods -n gatekeeper-system --no-headers 2>/dev/null | wc -l)
    CERTMANAGER_PODS=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | wc -l)
    TEMPLATE_COUNT=$(kubectl get constrainttemplates --no-headers 2>/dev/null | wc -l)
    CONSTRAINT_LIST=$(kubectl get constraints --no-headers 2>/dev/null)
    CERT_LIST=$(kubectl get certificates --all-namespaces --no-headers 2>/dev/null)
    VIOLATION_COUNT=$(kubectl get events --all-namespaces 2>/dev/null | grep -ic "violation\|denied\|forbidden")

    if [ "$GATEKEEPER_PODS" -gt 0 ]; then
        GATEKEEPER_STATUS="<span class=\"compliant\">Installed ($GATEKEEPER_PODS pods)</span>"
    else
        GATEKEEPER_STATUS="<span class=\"non-compliant\">Not installed</span>"
    fi

    if [ "$CERTMANAGER_PODS" -gt 0 ]; then
        CERTMANAGER_STATUS="<span class=\"compliant\">Installed ($CERTMANAGER_PODS pods)</span>"
    else
        CERTMANAGER_STATUS="<span class=\"non-compliant\">Not installed</span>"
    fi

    if [ "$VIOLATION_COUNT" -gt 0 ]; then
        VIOLATION_STATUS="<span class=\"warning\">$VIOLATION_COUNT recent violation-related events found</span>"
    else
        VIOLATION_STATUS="<span class=\"compliant\">No violation-related events found</span>"
    fi

    cat > $CLUSTER_REPORT << HTML_REPORT
<!DOCTYPE html>
<html>
<head>
    <title>Compliance Report - $cluster</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
        .section { margin: 20px 0; }
        .compliant { color: green; font-weight: bold; }
        .non-compliant { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        pre { background-color: #f5f5f5; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Compliance Report: $cluster</h1>
        <p>Generated at: $(date)</p>
    </div>

    <div class="section">
        <h2>Policy Engine Status</h2>
        <table>
            <tr><th>Component</th><th>Status</th></tr>
            <tr><td>OPA Gatekeeper</td><td>$GATEKEEPER_STATUS</td></tr>
            <tr><td>cert-manager</td><td>$CERTMANAGER_STATUS</td></tr>
            <tr><td>Constraint Templates</td><td>$TEMPLATE_COUNT registered</td></tr>
        </table>
    </div>

    <div class="section">
        <h2>Active Constraints</h2>
        <pre>$CONSTRAINT_LIST</pre>
    </div>

    <div class="section">
        <h2>Certificates</h2>
        <pre>$CERT_LIST</pre>
    </div>

    <div class="section">
        <h2>Policy Violations</h2>
        <p>$VIOLATION_STATUS</p>
    </div>
</body>
</html>
HTML_REPORT

    echo "Report written to $CLUSTER_REPORT"
done

echo
echo "All compliance reports generated in $REPORT_DIR/"
ls -la $REPORT_DIR/
