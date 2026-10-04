---
type: invariant
title: Each service owns one Postgres schema and nothing else
description: "A service reads and writes only its own schema through its own login role; another service's data is reached only through that service's HTTP API."
tags: [core, data, postgres]
status: stable
generated:
  by: wmd-deploy-builder/gpt-5.6-terra
  at: 2026-10-04T00:00:00Z
sources:
  - id: schemas
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/db/schemas.sql#L1-L25
  - id: boundaries
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/db/check-boundaries.sh#L6-L19
  - id: catalog-db
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L21-L26
  - id: notification-db
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L58-L63
  - id: order-db
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L95-L102
wardby:
  schema: 1
  roles: [builder, reviewer, planner]
  affects: [db/**, k8s/postgres.yaml, k8s/apps.yaml, docker-compose.yml]
  citations:
    - { id: schemas, repo: github:chfields/wmd-deploy, path: db/schemas.sql, lines: [1, 25], symbol: service role and schema setup, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:efbb1d5741e5ba10364580356506d84e79742a65b788ad407c67d2f7d4da1b1b }
    - { id: boundaries, repo: github:chfields/wmd-deploy, path: db/check-boundaries.sh, lines: [6, 19], symbol: try and cross-schema checks, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:9cfe46b26153d6e45024721aea4b26ad529757dd5390ca612a52fc0337adeb9a }
    - { id: catalog-db, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [21, 26], symbol: catalog Deployment database URL, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:9386c51bbf8c9dcfdf0e55230e9883f9cbfb5a6233b4877c80c6a9168c412611 }
    - { id: notification-db, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [58, 63], symbol: notification Deployment database URL, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:13b7c45fdd82cf6041fcb38112cd1c925a006d6ef7a6956a1da063163ae581d3 }
    - { id: order-db, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [95, 102], symbol: order Deployment database and service URLs, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:dc94f457fe52cabf69f6839a3a692db80569ad834e67beb87c15448d0b66f398 }
  confidence: high
---

Each of catalog, orders, and notification has its own login role and owned schema, with no grant on another service's schema; the boundary check proves their cross-schema reads fail. Order reaches catalog and notification through HTTP URLs. [^schemas] [^boundaries] [^catalog-db] [^notification-db] [^order-db]

Carried by: wmd-deploy, wmd-catalog-service, wmd-order-service, wmd-notification-service.

Why: preserve service data ownership at every interface.

[^schemas]: schemas
[^boundaries]: boundaries
[^catalog-db]: catalog-db
[^notification-db]: notification-db
[^order-db]: order-db
