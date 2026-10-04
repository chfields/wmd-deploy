---
type: invariant
title: Staging secrets are generated once and never rotated by deploy.sh
description: deploy.sh creates the wmd-db and wmd-bff secrets only if missing, so changing WMD_DEMO_PASSWORD or the DB passwords after the first deploy has no effect until the secret is deleted.
tags: [wmd-deploy, secrets, deploy]
status: stable
generated: { by: wmd-deploy-builder/gpt-5.6-terra, at: 2026-10-04T00:00:00Z }
sources:
  - { id: secret-creation, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/scripts/deploy.sh#L65-L78 }
  - { id: role-passwords, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/db/schemas.sql#L15-L17 }
wardby:
  schema: 1
  roles: [builder, reviewer]
  affects: [scripts/deploy.sh, k8s/apps.yaml, k8s/postgres.yaml]
  citations:
    - { id: secret-creation, repo: github:chfields/wmd-deploy, path: scripts/deploy.sh, lines: [65, 78], symbol: wmd-db and wmd-bff secret creation, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:09c33aa08ab9d92dffebbb93241c68d3107f27f1e9afc8c56bea2b73bdd4ed33 }
    - { id: role-passwords, repo: github:chfields/wmd-deploy, path: db/schemas.sql, lines: [15, 17], symbol: role password updates, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:3fe5eb3a8da103c16342a757afec43bd5801dcf77bdd4ce175a88736df658f4a }
  confidence: high
---

Secrets are created only when absent; WMD_DEMO_PASSWORD is required only on the first deploy and ignored afterwards. Rotating requires deleting the secret, and wmd-db role passwords are then reset by schemas.sql on the next deploy. [^secret-creation] [^role-passwords]

What to do: delete the intended secret before rotating it.

[^secret-creation]: secret-creation
[^role-passwords]: role-passwords
