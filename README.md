# wmd-deploy

How WMD Shop runs, locally and in staging. Part of the Wardby mobile demo.

## Local: the whole stack

```bash
docker compose up --build
```

The BFF is on http://localhost:8080; sign in as `demo@wmd.shop` / `demo`.
Point the app at it with `EXPO_PUBLIC_BFF_URL=http://localhost:8080`.

## Staging

`deploy.sh` builds each service repo's merged `origin/main` (from a clean
checkout, whatever branch the local copy is on) and rolls
`wmd-staging` forward: a namespace with a quota and network policies, Postgres
with one schema and role per service, then the services and the BFF. Run it
after merging; the merge is the approval. It always names its kubectl context,
so it never deploys to whichever cluster happens to be current.

**On a local kind cluster** (the default):

```bash
kind create cluster --name wmd --config kind/cluster.yaml
WMD_DEMO_PASSWORD=<choose one> scripts/deploy.sh
```

Images are built for this machine and loaded straight into the cluster. The
BFF is published on port 8088 of this machine; a phone on the same network
reaches it at `http://<this machine's LAN IP>:8088`.

**On GKE:**

```bash
WMD_TARGET=gke WMD_CONTEXT=<gke context> WMD_REGISTRY=us-central1-docker.pkg.dev/<project>/<repo> \
  WMD_DEMO_PASSWORD=<choose one> scripts/deploy.sh
```

Images are built for `linux/amd64` and pushed to the registry; the BFF gets a
load balancer.

Remove staging with `scripts/teardown.sh` (and the local cluster with
`kind delete cluster --name wmd`).

## Data ownership

`db/schemas.sql` gives each service its own schema and login role, with no
grant on any other schema. `db/check-boundaries.sh` proves it:

```bash
docker compose exec -T -e PGHOST=localhost -e PGDATABASE=wmd \
  -e CATALOG_DB_PASSWORD=catalog-local -e ORDERS_DB_PASSWORD=orders-local \
  -e NOTIFICATION_DB_PASSWORD=notification-local postgres sh /wmd/check-boundaries.sh
```

## Architecture knowledge

System-wide and repository-specific architecture knowledge lives in
[docs/knowledge/index.md](docs/knowledge/index.md).
