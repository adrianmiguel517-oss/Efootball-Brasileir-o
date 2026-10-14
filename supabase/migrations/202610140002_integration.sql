begin;
-- These RPCs are callable ONLY by the Edge Function's service role.
create function public.integration_secret() returns text language sql security definer set search_path='' as $$ select api_key from private.integration where id $$;
create function public.integration_config(config jsonb, secret text default null) returns void language plpgsql security definer set search_path='' as $$ begin
 if exists(select 1 from private.integration where lease_until>now()) then raise exception 'Aguarde a sincronização terminar.';end if;
 if secret is not null and length(trim(secret))>0 then update private.integration set api_key=trim(secret) where id;end if;
 update public.settings set value=config where id='integration';end $$;
create function public.integration_lock() returns uuid language plpgsql security definer set search_path='' as $$ declare token uuid=gen_random_uuid();begin
 update private.integration set lease_until=now()+interval '3 minutes',lease_id=token where id and (lease_until is null or lease_until<now());
 if not found then raise exception 'Já existe uma sincronização em andamento.';end if;
 update public.settings set value=value||jsonb_build_object('lastAttempt',now()) where id='integration';
 return token;end $$;
create function public.integration_unlock(token uuid) returns void language sql security definer set search_path='' as $$ update private.integration set lease_until=null,lease_id=null where lease_id=token $$;
create function public.integration_commit(token uuid, records jsonb, snapshots jsonb, refreshed text[], tournament text, season text, request_count integer) returns void language plpgsql security definer set search_path='' as $$
declare item jsonb; tab text; assignments text; begin
 perform 1 from private.integration where lease_id=token and lease_until>now() for update;
 if not found then raise exception 'Sincronização expirada. Tente novamente.';end if;
 if 'matches'=any(refreshed) then
 delete from public.matches m where source='copafacil' and tournament_id=tournament and season_id=season
 and not exists(select 1 from jsonb_array_elements(records) x where x->>'table'='matches' and x->'row'->>'id'=m.id);
 end if;
 for item in select value from jsonb_array_elements(records) loop
 tab=item->>'table';
 if tab not in ('clubs','phases','rounds','matches') or item->'row'->>'source'<>'copafacil' then raise exception 'Registro externo inválido';end if;
 select string_agg(format('%I=excluded.%I',column_name,column_name),',') into assignments from information_schema.columns where table_schema='public' and table_name=tab and column_name not in ('id','created_at');
 execute format('insert into public.%I select (jsonb_populate_record(null::public.%I,$1)).* on conflict(id) do update set %s',tab,tab,assignments) using item->'row';
 end loop;
 delete from public.external where tournament_id=tournament and season_id is not distinct from season and kind=any(refreshed);
 insert into public.external(id,kind,data,updated_at,season_id,tournament_id)
 select tournament||':'||coalesce(season,'')||':'||(v->>'id'),v->>'kind',v->'data',now()::text,season,tournament from jsonb_array_elements(snapshots) v;
 update public.settings set value=value||jsonb_build_object('lastSync',now()) where id='integration';
 insert into public.sync_runs(status,message) values('Sucesso',request_count||' consultas; snapshot publicado.');
 end $$;
revoke all on function public.integration_secret(),public.integration_config(jsonb,text),public.integration_lock(),public.integration_unlock(uuid),public.integration_commit(uuid,jsonb,jsonb,text[],text,text,integer) from public,anon,authenticated;
grant execute on function public.integration_secret(),public.integration_config(jsonb,text),public.integration_lock(),public.integration_unlock(uuid),public.integration_commit(uuid,jsonb,jsonb,text[],text,text,integer) to service_role;
commit;
