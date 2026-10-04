-- One schema and one login role per service. A role owns only its schema and
-- has no grant on any other, so a service can't read another service's data.
-- Idempotent: safe to run on every deploy. Passwords come in as psql variables.
\set ON_ERROR_STOP on

revoke create on schema public from public;

select format('create role %I login password %L', 'catalog_svc', :'catalog_password')
 where not exists (select from pg_roles where rolname = 'catalog_svc') \gexec
select format('create role %I login password %L', 'orders_svc', :'orders_password')
 where not exists (select from pg_roles where rolname = 'orders_svc') \gexec
select format('create role %I login password %L', 'notification_svc', :'notification_password')
 where not exists (select from pg_roles where rolname = 'notification_svc') \gexec

alter role catalog_svc password :'catalog_password';
alter role orders_svc password :'orders_password';
alter role notification_svc password :'notification_password';

create schema if not exists catalog authorization catalog_svc;
create schema if not exists orders authorization orders_svc;
create schema if not exists notification authorization notification_svc;

alter role catalog_svc set search_path = catalog;
alter role orders_svc set search_path = orders;
alter role notification_svc set search_path = notification;

-- Per-role connection caps so one service can't starve the others.
alter role catalog_svc connection limit 20;
alter role orders_svc connection limit 20;
alter role notification_svc connection limit 20;
