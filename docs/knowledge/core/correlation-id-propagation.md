---
type: convention
title: Every request carries one x-correlation-id end to end
description: Each service accepts x-correlation-id (or makes one), logs it, returns it, and forwards it on every outbound call.
tags: [core, observability, http]
status: stable
generated: { by: wmd-deploy-builder/gpt-5.6-terra, at: 2026-10-04T00:00:00Z }
sources:
  - { id: order-urls, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L95-L102 }
  - { id: bff-urls, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L135-L143 }
wardby:
  schema: 1
  roles: [builder, reviewer, planner]
  affects: [k8s/apps.yaml, docker-compose.yml]
  citations:
    - { id: order-urls, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [95, 102], symbol: order Deployment outbound URLs, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:dc94f457fe52cabf69f6839a3a692db80569ad834e67beb87c15448d0b66f398 }
    - { id: bff-urls, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [135, 143], symbol: bff Deployment outbound URLs, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:b8eff2451da57e4bdc2706f2ea30fb4107d647ebe34d8a9c61615f60ebe1c164 }
  confidence: high
---

Requests flow app → bff → order → catalog/notification along the configured URLs; every hop must accept, log, return, and forward the same x-correlation-id so one identifier traces a request across them. [^order-urls] [^bff-urls]

This repository wires the call graph but does not implement the header; implementations live in the carrying repositories.

Carried by: wmd-deploy, wmd-bff, wmd-catalog-service, wmd-order-service, wmd-notification-service.

What to do: preserve the identifier on every outbound call.

[^order-urls]: order-urls
[^bff-urls]: bff-urls
