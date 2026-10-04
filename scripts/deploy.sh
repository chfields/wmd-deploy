#!/usr/bin/env bash
# Builds each repo's current commit and rolls staging forward. Two targets:
#   kind (local):  WMD_DEMO_PASSWORD=... scripts/deploy.sh
#   GKE:           WMD_TARGET=gke WMD_REGISTRY=us-central1-docker.pkg.dev/<project>/<repo> WMD_DEMO_PASSWORD=... scripts/deploy.sh
# Run it after merging; the merge is the approval. Repos are expected next to this one.
set -euo pipefail
WMD_TARGET="${WMD_TARGET:-kind}"
export WMD_NAMESPACE="${WMD_NAMESPACE:-wmd-staging}"
case "$WMD_TARGET" in
  kind)
    WMD_KIND_CLUSTER="${WMD_KIND_CLUSTER:-wmd}"
    WMD_CONTEXT="${WMD_CONTEXT:-kind-$WMD_KIND_CLUSTER}"
    WMD_REGISTRY="${WMD_REGISTRY:-wmd.local}"
    ;;
  gke)
    : "${WMD_REGISTRY:?set WMD_REGISTRY, e.g. us-central1-docker.pkg.dev/<project>/<repo>}"
    : "${WMD_CONTEXT:?set WMD_CONTEXT to the GKE kubectl context}"
    ;;
  *) echo "WMD_TARGET must be kind or gke" >&2; exit 1 ;;
esac
# Always name the context, so a deploy can't land on whatever cluster is current.
# (An array, not a function: macOS bash 3.2 exits on a failing function used as a condition.)
KUBECTL=(kubectl --context "$WMD_CONTEXT")
here="$(cd "$(dirname "$0")/.." && pwd)"
root="$(cd "$here/.." && pwd)"

image_for() { # repo -> registry/repo:<short sha>, built and pushed if missing
  local repo="$1" sha ref
  sha="$(git -C "$root/$repo" rev-parse --short=12 HEAD)"
  if [ -n "$(git -C "$root/$repo" status --porcelain)" ]; then
    echo "$repo has uncommitted changes; commit or stash them first" >&2; exit 1
  fi
  ref="$WMD_REGISTRY/$repo:$sha"
  if [ "$WMD_TARGET" = kind ]; then
    if ! docker image inspect "$ref" >/dev/null 2>&1; then
      echo "building $ref" >&2
      docker build -t "$ref" "$root/$repo" >&2
    fi
    kind load docker-image "$ref" --name "$WMD_KIND_CLUSTER" >&2
  elif ! docker manifest inspect "$ref" >/dev/null 2>&1; then
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

render "$here/k8s/namespace.yaml" | "${KUBECTL[@]}" apply -f -

# Secrets are generated once and kept; set WMD_DEMO_PASSWORD on the first deploy.
if ! "${KUBECTL[@]}" -n "$WMD_NAMESPACE" get secret wmd-db >/dev/null 2>&1; then
  "${KUBECTL[@]}" -n "$WMD_NAMESPACE" create secret generic wmd-db \
    --from-literal=admin-password="$(openssl rand -hex 24)" \
    --from-literal=catalog-password="$(openssl rand -hex 24)" \
    --from-literal=orders-password="$(openssl rand -hex 24)" \
    --from-literal=notification-password="$(openssl rand -hex 24)"
fi
if ! "${KUBECTL[@]}" -n "$WMD_NAMESPACE" get secret wmd-bff >/dev/null 2>&1; then
  : "${WMD_DEMO_PASSWORD:?set WMD_DEMO_PASSWORD for the first deploy}"
  "${KUBECTL[@]}" -n "$WMD_NAMESPACE" create secret generic wmd-bff \
    --from-literal=auth-secret="$(openssl rand -hex 32)" \
    --from-literal=demo-password="$WMD_DEMO_PASSWORD"
fi

"${KUBECTL[@]}" -n "$WMD_NAMESPACE" create configmap wmd-db-scripts \
  --from-file="$here/db/init.sh" --from-file="$here/db/schemas.sql" --from-file="$here/db/check-boundaries.sh" \
  --dry-run=client -o yaml | "${KUBECTL[@]}" apply -f -

"${KUBECTL[@]}" -n "$WMD_NAMESPACE" delete job wmd-db-init --ignore-not-found
render "$here/k8s/postgres.yaml" | "${KUBECTL[@]}" apply -f -
"${KUBECTL[@]}" -n "$WMD_NAMESPACE" rollout status statefulset/postgres --timeout=10m
"${KUBECTL[@]}" -n "$WMD_NAMESPACE" wait --for=condition=complete job/wmd-db-init --timeout=10m

render "$here/k8s/apps.yaml" | "${KUBECTL[@]}" apply -f -
if [ "$WMD_TARGET" = kind ]; then
  # kind has no load balancer: publish the BFF on the node port kind/cluster.yaml maps to :8088.
  "${KUBECTL[@]}" -n "$WMD_NAMESPACE" patch service bff --type merge \
    -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":8080,"nodePort":30080}]}}' >/dev/null
fi
for app in catalog notification order bff; do
  "${KUBECTL[@]}" -n "$WMD_NAMESPACE" rollout status "deployment/$app" --timeout=10m
done

echo "deployed to $WMD_CONTEXT/$WMD_NAMESPACE:"
echo "  catalog       $WMD_CATALOG_IMAGE"
echo "  notification  $WMD_NOTIFICATION_IMAGE"
echo "  order         $WMD_ORDER_IMAGE"
echo "  bff           $WMD_BFF_IMAGE"
if [ "$WMD_TARGET" = kind ]; then
  echo "BFF: http://localhost:8088 (from a phone: http://<this machine's LAN IP>:8088)"
else
  ip="$("${KUBECTL[@]}" -n "$WMD_NAMESPACE" get service bff -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
  echo "BFF: http://${ip:-<pending: rerun, or "${KUBECTL[@]}" get service bff>}"
fi
