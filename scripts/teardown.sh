#!/usr/bin/env bash
# Deletes staging: the namespace, its database volume and its load balancer.
set -euo pipefail
ns="${WMD_NAMESPACE:-wmd-staging}"
: "${WMD_CONTEXT:=kind-wmd}"
kubectl --context "$WMD_CONTEXT" delete namespace "$ns" --wait=true
# Local cluster: kind delete cluster --name wmd
