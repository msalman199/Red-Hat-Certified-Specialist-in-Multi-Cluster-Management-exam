#!/bin/bash

REPORT_FILE="compliance-report-$(date +%Y%m%d-%H%M%S).txt"

echo "=== RHACM Multi-Cluster Compliance Report ===" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "Operator: $(oc whoami)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Cluster Overview ===" >> $REPORT_FILE
oc get managedclusters -o wide >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Policy Compliance Summary ===" >> $REPORT_FILE
oc get policies -o custom-columns=NAME:.metadata.name,COMPLIANT:.status.compliant,PLACEMENT:.spec.placement >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Application Deployment Status ===" >> $REPORT_FILE
oc get applications -o wide >> $REPORT_FILE
oc get subscriptions -o wide >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "=== Detailed Policy Status ===" >> $REPORT_FILE
for policy in $(oc get policies -o jsonpath='{.items[*].metadata.name}'); do
    echo "--- Policy: $policy ---" >> $REPORT_FILE
    oc describe policy $policy >> $REPORT_FILE
    echo "" >> $REPORT_FILE
done

echo "Report generated: $REPORT_FILE"
echo "First 20 lines of report:"
head -20 $REPORT_FILE
