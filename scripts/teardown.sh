#!/usr/bin/env bash
# Deletes staging: the namespace, its database volume and its load balancer.
set -euo pipefail
ns="${WMD_NAMESPACE:-wmd-staging}"
kubectl delete namespace "$ns" --wait=true
