#!/bin/bash

echo "Starting coordinated rolling update..."

# Update dev first
echo "Updating development environment..."
argocd app sync dev-cluster-guestbook
argocd app wait dev-cluster-guestbook --health

# Update staging after dev is healthy
echo "Updating staging environment..."
argocd app sync staging-cluster-guestbook
argocd app wait staging-cluster-guestbook --health

# Update production after staging is healthy
echo "Updating production environment..."
argocd app sync prod-cluster-guestbook
argocd app wait prod-cluster-guestbook --health

echo "Rolling update completed successfully!"
