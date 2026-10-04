---
type: invariant
title: Orders reserve stock first and are confirmed only after notification
description: An order exists only after catalog-service reserves all its stock in one transaction, and moves from pending to confirmed only when notification-service accepts the confirmation, which is idempotent per order and kind.
tags: [core, orders, domain]
status: stable
generated: { by: wmd-deploy-builder/gpt-5.6-terra, at: 2026-10-04T00:00:00Z }
sources:
  - { id: staging-order-urls, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L95-L102 }
  - { id: local-order-urls, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/docker-compose.yml#L37-L43 }
wardby:
  schema: 1
  roles: [builder, reviewer, planner]
  affects: [k8s/apps.yaml, docker-compose.yml]
  citations:
    - { id: staging-order-urls, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [95, 102], symbol: order Deployment catalog and notification URLs, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:dc94f457fe52cabf69f6839a3a692db80569ad834e67beb87c15448d0b66f398 }
    - { id: local-order-urls, repo: github:chfields/wmd-deploy, path: docker-compose.yml, lines: [37, 43], symbol: order compose service catalog and notification URLs, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:fdb36144baa1758e8872ff5cf33beaae61a4c8398e22308d6042da4c2ccbe905 }
  confidence: medium
---

order-service is wired to catalog for stock reservation and notification for confirmation; an order is created only after reservation succeeds and moves pending → confirmed only after notification accepts, idempotently per order and kind. [^staging-order-urls] [^local-order-urls]

Carried by: wmd-deploy, wmd-catalog-service, wmd-order-service, wmd-notification-service, wmd-app.

Why: reserve all stock in one transaction before creating the order.

[^staging-order-urls]: staging-order-urls
[^local-order-urls]: local-order-urls
