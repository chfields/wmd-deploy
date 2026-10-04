---
type: invariant
title: The BFF is the only API the app and the outside world reach
description: wmd-app calls only wmd-bff; services stay internal and trust the user id the BFF passes, never one taken from a request body.
tags: [core, security, networking]
status: stable
generated:
  by: wmd-deploy-builder/gpt-5.6-terra
  at: 2026-10-04T00:00:00Z
sources:
  - id: policies
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/namespace.yaml#L20-L43
  - id: services
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/k8s/apps.yaml#L3-L123
  - id: local-bff
    url: https://github.com/chfields/wmd-deploy/blob/6c9fce7af7c03c110a207e0c073ac4e36abfd1d3/docker-compose.yml#L45-L54
wardby:
  schema: 1
  roles: [builder, reviewer, planner]
  affects: [k8s/namespace.yaml, k8s/apps.yaml, docker-compose.yml, kind/cluster.yaml]
  citations:
    - { id: policies, repo: github:chfields/wmd-deploy, path: k8s/namespace.yaml, lines: [20, 43], symbol: wmd-internal-only and wmd-bff-public NetworkPolicies, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:c62d17db512785e98c57e21d9426977967a362367e8351eb9e863a2beadbaf80 }
    - { id: services, repo: github:chfields/wmd-deploy, path: k8s/apps.yaml, lines: [3, 123], symbol: service definitions, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:4a28c95a50e8c04e9c3e8325631ec2c27d37cafb38b1b4aa0836aa3cd67bfc7d }
    - { id: local-bff, repo: github:chfields/wmd-deploy, path: docker-compose.yml, lines: [45, 54], symbol: bff compose service port publishing, sha: 6c9fce7af7c03c110a207e0c073ac4e36abfd1d3, spanHash: sha256:2756370238eb7ae78421d3cbe9982452b17b649fcebbc34a542341a0b27e8b7d }
  confidence: high
---

In staging, only bff accepts ingress from outside the namespace and has an exposed Service; catalog, notification, and order are ClusterIP services for pod-to-pod access. Locally, only bff publishes a port. [^policies] [^services] [^local-bff]

Carried by: wmd-deploy, wmd-bff, wmd-app, wmd-order-service, wmd-notification-service.

Why: keep the BFF as the sole public API and user-identity boundary.

[^policies]: policies
[^services]: services
[^local-bff]: local-bff
