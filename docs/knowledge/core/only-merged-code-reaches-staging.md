---
type: decision
title: Only merged main reaches staging
description: deploy.sh builds every service from its origin/main in a clean checkout, so staging never runs unreviewed code.
tags: [core, deploy, process]
status: stable
generated: { by: wmd-deploy-builder/gpt-5.6-terra, at: 2026-10-04T00:00:00Z }
sources:
  - { id: image-for, url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/scripts/deploy.sh#L33-L59 }
wardby:
  schema: 1
  roles: [builder, reviewer, planner]
  affects: [scripts/deploy.sh]
  citations:
    - { id: image-for, repo: github:chfields/wmd-deploy, path: scripts/deploy.sh, lines: [33, 59], symbol: image_for and service image calls, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:414eb9df557a90a7f8259ccaaa04711e9eb451da2b6754c70814c91e603db97d }
  confidence: high
---

deploy.sh fetches each service repository's origin/main, builds it from a detached worktree regardless of local branch or uncommitted changes, and tags the image by that SHA; the merge is the approval, so nothing unmerged reaches staging. [^image-for]

Carried by: wmd-deploy, wmd-catalog-service, wmd-order-service, wmd-notification-service, wmd-bff.

Why: staging must run only reviewed, merged code.

[^image-for]: image-for
