#!/bin/bash

echo "=== RHACM Log Collection Script ==="
LOG_DIR="rhacm-logs-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_DIR"

echo "Collecting RHACM component logs..."

oc logs -n open-cluster-management deployment/multicluster-operators-hub > "$LOG_DIR/hub-operator.log" 2>&1
oc logs -n open-cluster-management deployment/cluster-manager > "$LOG_DIR/cluster-manager.log" 2>&1
oc logs -n open-cluster-management deployment/multicluster-operators-application > "$LOG_DIR/application-lifecycle.log" 2>&1
oc logs -n open-cluster-management deployment/governance-policy-framework > "$LOG_DIR/policy-framework.log" 2>&1
oc logs -n open-cluster-management deployment/search-collector > "$LOG_DIR/search-collector.log" 2>&1

echo "Logs collected in directory: $LOG_DIR"
ls -la "$LOG_DIR/"
