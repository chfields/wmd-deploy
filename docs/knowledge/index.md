# Architecture knowledge

## Core

- [Each service owns one Postgres schema and nothing else](core/service-data-ownership.md)
- [The BFF is the only API the app and the outside world reach](core/bff-only-public-api.md)
- [Every request carries one x-correlation-id end to end](core/correlation-id-propagation.md)
- [Errors are {"error": {"code", "message"}} with stable codes](core/error-contract.md)
- [Orders reserve stock first and are confirmed only after notification](core/order-lifecycle.md)
- [Only merged main reaches staging](core/only-merged-code-reaches-staging.md)

## This repository

- [db/schemas.sql runs on every deploy and must stay idempotent](schemas-sql-reruns-every-deploy.md)
- [Staging secrets are generated once and never rotated by deploy.sh](staging-secrets-created-once.md)
