#!/usr/bin/env bash
# Builds each repo's current commit, pushes it, and rolls staging forward.
#   WMD_REGISTRY=us-central1-docker.pkg.dev/<project>/<repo> WMD_DEMO_PASSWORD=... scripts/deploy.sh
# Run it after merging; the merge is the approval. Repos are expected next to this one.
set -euo pipefail
: "${WMD_REGISTRY:?set WMD_REGISTRY, e.g. us-central1-docker.pkg.dev/<project>/<repo>}"
export WMD_NAMESPACE="${WMD_NAMESPACE:-wmd-staging}"
here="$(cd "$(dirname "$0")/.." && pwd)"
root="$(cd "$here/.." && pwd)"

image_for() { # repo -> registry/repo:<short sha>, built and pushed if missing
  local repo="$1" sha ref
  sha="$(git -C "$root/$repo" rev-parse --short=12 HEAD)"
  if [ -n "$(git -C "$root/$repo" status --porcelain)" ]; then
    echo "$repo has uncommitted changes; commit or stash them first" >&2; exit 1
  fi
  ref="$WMD_REGISTRY/$repo:$sha"
  if ! docker manifest inspect "$ref" >/dev/null 2>&1; then
    echo "building $ref" >&2
    docker buildx build --platform linux/amd64 --push -t "$ref" "$root/$repo" >&2
  fi
  echo "$ref"
}

export WMD_CATALOG_IMAGE="$(image_for wmd-catalog-service)"
export WMD_NOTIFICATION_IMAGE="$(image_for wmd-notification-service)"
export WMD_ORDER_IMAGE="$(image_for wmd-order-service)"
export WMD_BFF_IMAGE="$(image_for wmd-bff)"

render() { envsubst '${WMD_NAMESPACE} ${WMD_CATALOG_IMAGE} ${WMD_NOTIFICATION_IMAGE} ${WMD_ORDER_IMAGE} ${WMD_BFF_IMAGE}' < "$1"; }

render "$here/k8s/namespace.yaml" | kubectl apply -f -

# Secrets are generated once and kept; set WMD_DEMO_PASSWORD on the first deploy.
if ! kubectl -n "$WMD_NAMESPACE" get secret wmd-db >/dev/null 2>&1; then
  kubectl -n "$WMD_NAMESPACE" create secret generic wmd-db \
    --from-literal=admin-password="$(openssl rand -hex 24)" \
    --from-literal=catalog-password="$(openssl rand -hex 24)" \
    --from-literal=orders-password="$(openssl rand -hex 24)" \
    --from-literal=notification-password="$(openssl rand -hex 24)"
fi
if ! kubectl -n "$WMD_NAMESPACE" get secret wmd-bff >/dev/null 2>&1; then
  : "${WMD_DEMO_PASSWORD:?set WMD_DEMO_PASSWORD for the first deploy}"
  kubectl -n "$WMD_NAMESPACE" create secret generic wmd-bff \
    --from-literal=auth-secret="$(openssl rand -hex 32)" \
    --from-literal=demo-password="$WMD_DEMO_PASSWORD"
fi

kubectl -n "$WMD_NAMESPACE" create configmap wmd-db-scripts \
  --from-file="$here/db/init.sh" --from-file="$here/db/schemas.sql" --from-file="$here/db/check-boundaries.sh" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$WMD_NAMESPACE" delete job wmd-db-init --ignore-not-found
render "$here/k8s/postgres.yaml" | kubectl apply -f -
kubectl -n "$WMD_NAMESPACE" rollout status statefulset/postgres --timeout=10m
kubectl -n "$WMD_NAMESPACE" wait --for=condition=complete job/wmd-db-init --timeout=10m

render "$here/k8s/apps.yaml" | kubectl apply -f -
for app in catalog notification order bff; do
  kubectl -n "$WMD_NAMESPACE" rollout status "deployment/$app" --timeout=10m
done

ip="$(kubectl -n "$WMD_NAMESPACE" get service bff -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "deployed:"
echo "  catalog       $WMD_CATALOG_IMAGE"
echo "  notification  $WMD_NOTIFICATION_IMAGE"
echo "  order         $WMD_ORDER_IMAGE"
echo "  bff           $WMD_BFF_IMAGE"
echo "BFF: http://${ip:-<pending: rerun or kubectl get svc bff>}"
