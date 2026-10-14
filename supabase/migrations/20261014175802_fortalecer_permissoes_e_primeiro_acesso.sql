-- Reduce Supabase default ACLs, protect privileged lookups, and bootstrap ONLY verified league admins.
begin;
alter table private.integration enable row level security;
create policy integration_service_only on private.integration for all to service_role using(true) with check(true);

alter function public.liga_role() set schema private;
alter function public.authorize_member(text,text) set schema private;
alter function public.remove_member(uuid) set schema private;
create function public.liga_role() returns text language sql stable security invoker set search_path='' as $$select private.liga_role()$$;
create function public.authorize_member(member_email text,member_role text) returns void language sql security invoker set search_path='' as $$select private.authorize_member(member_email,member_role)$$;
create function public.remove_member(member_id uuid) returns void language sql security invoker set search_path='' as $$select private.remove_member(member_id)$$;
revoke all on function public.liga_role(),public.authorize_member(text,text),public.remove_member(uuid) from public,anon,authenticated;
grant execute on function public.liga_role() to anon,authenticated;
grant execute on function public.authorize_member(text,text),public.remove_member(uuid) to authenticated;

create function private.bootstrap_verified_admin() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if new.email_confirmed_at is not null and lower(new.email) in ('adrianmiguel517@gmail.com','paiivavitor07@gmail.com') then
 insert into public.members(id,email,role) values(new.id,lower(new.email),'admin') on conflict(id) do nothing;
 end if;
 return new;
end $$;
create trigger bootstrap_verified_admin after insert or update of email,email_confirmed_at on auth.users for each row execute function private.bootstrap_verified_admin();
insert into public.members(id,email,role)
select id,lower(email),'admin' from auth.users where email_confirmed_at is not null and lower(email) in ('adrianmiguel517@gmail.com','paiivavitor07@gmail.com') on conflict(id) do nothing;

revoke all on all functions in schema private from public,anon,authenticated;
grant usage on schema private to anon,authenticated;
grant execute on function private.liga_role() to anon,authenticated;
grant execute on function private.authorize_member(text,text),private.remove_member(uuid) to authenticated;
revoke all on all tables in schema private from public,anon,authenticated;

do $$declare t text;begin
 for t in select tablename from pg_tables where schemaname='public' and tablename in ('seasons','phases','rounds','clubs','players','memberships','matches','events','appearances','news','videos','transfers','titles','awards','sponsors','banners') loop
 execute format('revoke all on public.%I from anon,authenticated',t);
 execute format('grant select on public.%I to anon,authenticated',t);
 execute format('grant insert,update,delete on public.%I to authenticated',t);
 end loop;
end $$;
revoke all on public.members,public.audit,public.settings,public.external,public.sync_runs from anon,authenticated;
grant select on public.members,public.audit,public.settings,public.external,public.sync_runs to authenticated;
grant select on public.settings,public.external to anon;
drop policy read_external on public.external;
create policy read_external on public.external for select to authenticated using(kind in ('table','ranking','matches') or public.liga_role()='admin');
-- The platform creates this event-trigger function in some projects. It is never a client API.
do $$begin
 if to_regprocedure('public.rls_auto_enable()') is not null then execute 'revoke all on function public.rls_auto_enable() from public,anon,authenticated';end if;
end $$;

create index matches_season_round_idx on public.matches(season_id,round);
create index events_match_minute_idx on public.events(match_id,minute);
create index external_scope_idx on public.external(tournament_id,season_id,kind);
create index audit_created_idx on public.audit(created_at desc);
create index sync_runs_created_idx on public.sync_runs(created_at desc);
-- Index FK columns that have no non-partial leading index yet.
do $$declare r record;begin
 for r in select distinct c.conrelid,ns.nspname as schema_name,t.relname as table_name,a.attname as column_name,a.attnum
 from pg_constraint c join pg_class t on t.oid=c.conrelid join pg_namespace ns on ns.oid=t.relnamespace
 join pg_attribute a on a.attrelid=c.conrelid and a.attnum=any(c.conkey)
 where c.contype='f' and ns.nspname='public' and not exists(select 1 from pg_index i where i.indrelid=c.conrelid and i.indpred is null and i.indkey[0]=a.attnum)
 loop execute format('create index if not exists %I on %I.%I(%I)',r.table_name||'_'||r.column_name||'_fk_idx',r.schema_name,r.table_name,r.column_name);end loop;
end $$;
commit;
