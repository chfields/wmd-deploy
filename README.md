# wmd-deploy

How WMD Shop runs, locally and in staging. Part of the Wardby mobile demo.

## Local: the whole stack

```bash
docker compose up --build
```

The BFF is on http://localhost:8080; sign in as `demo@wmd.shop` / `demo`.
Point the app at it with `EXPO_PUBLIC_BFF_URL=http://localhost:8080`.

## Staging on GKE

```bash
WMD_REGISTRY=us-central1-docker.pkg.dev/<project>/<repo> WMD_DEMO_PASSWORD=<choose one> scripts/deploy.sh
```

`deploy.sh` builds each service repo's current commit (`linux/amd64`), pushes
it, and rolls `wmd-staging` forward: namespace with quota and network
policies, Postgres with one schema and role per service, then the services
and the BFF behind a load balancer. Run it after merging; the merge is the
approval. Remove staging with `scripts/teardown.sh`.

## Data ownership

`db/schemas.sql` gives each service its own schema and login role, with no
grant on any other schema. `db/check-boundaries.sh` proves it:

```bash
docker compose exec -T -e PGHOST=localhost -e PGDATABASE=wmd \
  -e CATALOG_DB_PASSWORD=catalog-local -e ORDERS_DB_PASSWORD=orders-local \
  -e NOTIFICATION_DB_PASSWORD=notification-local postgres sh /wmd/check-boundaries.sh
```
