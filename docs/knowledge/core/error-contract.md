---
type: convention
title: 'Errors are {"error": {"code", "message"}} with stable codes'
description: Every API error uses this shape, and codes are stable identifiers clients branch on, so they are never renamed.
tags: [core, api, errors]
status: stable
generated: { by: wmd-deploy-builder/gpt-5.6-terra, at: 2026-10-04T00:00:00Z }
sources:
  - { id: deployments, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L11-L155 }
wardby:
  schema: 1
  roles: [builder, reviewer, planner]
  affects: [k8s/apps.yaml, docker-compose.yml]
  citations:
    - { id: deployments, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [11, 155], symbol: catalog notification order and bff Deployments, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:bb38fe64971300ddbf7d319c178ab77f8be57f36f6594e3bbe7a83977ca6d19c }
  confidence: medium
---

Every API in the stack—catalog, notification, order, and bff—returns errors as {"error": {"code", "message"}}; codes are stable identifiers that the app and other services branch on, so renaming one is a breaking change. [^deployments]

This repository defines the stack APIs but not the error shape; implementations live in the carrying repositories.

Carried by: wmd-deploy, wmd-catalog-service, wmd-order-service, wmd-notification-service, wmd-bff, wmd-app.

What to do: add codes, but never rename existing ones.

[^deployments]: deployments
