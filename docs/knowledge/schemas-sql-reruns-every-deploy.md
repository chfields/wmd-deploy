---
type: invariant
title: db/schemas.sql runs on every deploy and must stay idempotent
description: deploy.sh deletes and recreates the wmd-db-init job each deploy, so every statement in schemas.sql must be safe to re-run against an existing database.
tags: [wmd-deploy, postgres, deploy]
status: stable
generated: { by: wmd-deploy-builder/gpt-5.6-terra, at: 2026-10-04T00:00:00Z }
sources:
  - { id: deploy-init, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/scripts/deploy.sh#L80-L87 }
  - { id: init-job, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/postgres.yaml#L42-L69 }
  - { id: guarded-schema, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/db/schemas.sql#L8-L21 }
wardby:
  schema: 1
  roles: [builder, reviewer]
  affects: [db/schemas.sql, db/init.sh, k8s/postgres.yaml, scripts/deploy.sh]
  citations:
    - { id: deploy-init, repo: github:chfields/wmd-deploy, path: scripts/deploy.sh, lines: [80, 87], symbol: database init job recreation and wait, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:209bb96bfe3d9844cf6602d62f6e20fdf2dfea2f2e434654a7948100d91f0f1c }
    - { id: init-job, repo: github:chfields/wmd-deploy, path: k8s/postgres.yaml, lines: [42, 69], symbol: wmd-db-init Job, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:504f4c5649177f364dd5b773f9c270a7df4112a97fd7c5f11d108c2741cb9342 }
    - { id: guarded-schema, repo: github:chfields/wmd-deploy, path: db/schemas.sql, lines: [8, 21], symbol: guarded role and schema creation, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:98fec16ca4c947c117c8272d71dc1a9357161f3be7f5b99852192143eb29047a }
  confidence: high
---

The init Job reruns schemas.sql against the live staging database on every deploy; new statements must use guarded forms (if not exists, gexec with not exists, or alter) or the deploy fails while waiting for the Job. [^deploy-init] [^init-job] [^guarded-schema]

What to do: make every schema change safe to rerun.

[^deploy-init]: deploy-init
[^init-job]: init-job
[^guarded-schema]: guarded-schema
