#!/bin/bash

# Compliance Validation Script for Multi-Cluster Governance
CLUSTERS=("cluster-1" "cluster-2")
REPORT_FILE="compliance-report-$(date +%Y%m%d-%H%M%S).txt"

echo "=== Multi-Cluster Compliance Validation Report ===" > $REPORT_FILE
echo "Generated at: $(date)" >> $REPORT_FILE
echo >> $REPORT_FILE

for cluster in "${CLUSTERS[@]}"; do
    echo "Processing cluster: $cluster"
    echo "=== Cluster: $cluster ===" >> $REPORT_FILE

    kubectl config use-context $cluster
    if [ $? -ne 0 ]; then
        echo "ERROR: Cannot switch to cluster $cluster" >> $REPORT_FILE
        continue
    fi

    echo "--- Gatekeeper Status ---" >> $REPORT_FILE
    gatekeeper_pods=$(kubectl get pods -n gatekeeper-system --no-headers 2>/dev/null | wc -l)
    if [ $gatekeeper_pods -gt 0 ]; then
        echo "Gatekeeper is installed ($gatekeeper_pods pods)" >> $REPORT_FILE
        kubectl get pods -n gatekeeper-system >> $REPORT_FILE 2>&1
    else
        echo "Gatekeeper is NOT installed" >> $REPORT_FILE
    fi
    echo >> $REPORT_FILE

    echo "--- Constraint Templates ---" >> $REPORT_FILE
    kubectl get constrainttemplates --no-headers 2>/dev/null >> $REPORT_FILE
    echo >> $REPORT_FILE

    echo "--- Active Constraints ---" >> $REPORT_FILE
    kubectl get constraints --no-headers 2>/dev/null >> $REPORT_FILE
    echo >> $REPORT_FILE

    echo "--- Cert-Manager Status ---" >> $REPORT_FILE
    certmanager_pods=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | wc -l)
    if [ $certmanager_pods -gt 0 ]; then
        echo "Cert-Manager is installed ($certmanager_pods pods)" >> $REPORT_FILE
        kubectl get pods -n cert-manager >> $REPORT_FILE 2>&1
    else
        echo "Cert-Manager is NOT installed" >> $REPORT_FILE
    fi
    echo >> $REPORT_FILE

    echo "--- Certificates Status ---" >> $REPORT_FILE
    kubectl get certificates --all-namespaces >> $REPORT_FILE 2>&1
    echo >> $REPORT_FILE

    echo "--- Policy Violations (recent events) ---" >> $REPORT_FILE
    kubectl get events --all-namespaces 2>/dev/null | grep -i "violation\|denied\|forbidden" >> $REPORT_FILE
    echo >> $REPORT_FILE

    echo "========================================" >> $REPORT_FILE
    echo >> $REPORT_FILE
done

echo "Compliance validation complete. Report saved to: $REPORT_FILE"
cat $REPORT_FILE
