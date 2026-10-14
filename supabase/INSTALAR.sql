-- Execute uma vez no SQL Editor do Supabase. Não executa as migrações SQLite antigas.
begin;
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create table public.seasons (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "name" text not null check (length(trim("name")) > 0), "year" integer not null check ("year" >= 0), "status" text not null check (length(trim("status")) > 0) check ("status" in ('Planejada','Em andamento','Encerrada')), "rules" text, "tiebreakers" text not null check (length(trim("tiebreakers")) > 0) check ("tiebreakers" in ('points,wins,gd,gf','points,gd,gf,wins')), "qualify" integer check ("qualify" >= 0), "relegate" integer check ("relegate" >= 0));
create table public.clubs (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "name" text not null check (length(trim("name")) > 0), "short" text not null check (length(trim("short")) > 0), "color" text, "image" text check ("image" is null or "image" ~ '^https://'), "manager" text, "formation" text, "bio" text, tournament_id text);
create table public.players (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "name" text not null check (length(trim("name")) > 0), "position" text not null check (length(trim("position")) > 0) check ("position" in ('GOL','ZAG','LD','LE','VOL','MC','MEI','PD','PE','SA','CA')), "overall" integer check ("overall" >= 0), "image" text check ("image" is null or "image" ~ '^https://'), "bio" text);
create table public.memberships (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "season_id" text not null check (length(trim("season_id")) > 0), "club_id" text not null check (length(trim("club_id")) > 0), "player_id" text not null check (length(trim("player_id")) > 0), "role" text not null check (length(trim("role")) > 0) check ("role" in ('Titular','Reserva')), "number" integer check ("number" >= 0), "started" text, "ended" text);
create table public.matches (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "season_id" text not null check (length(trim("season_id")) > 0), "home_id" text not null check (length(trim("home_id")) > 0), "away_id" text not null check (length(trim("away_id")) > 0), "round" integer not null check ("round" >= 0), "phase" text not null check (length(trim("phase")) > 0), "kickoff" text, "status" text not null check (length(trim("status")) > 0) check ("status" in ('Agendado','Ao vivo','Encerrado','Adiado')), "home_score" integer check ("home_score" >= 0), "away_score" integer check ("away_score" >= 0), "home_possession" integer check ("home_possession" >= 0), "away_possession" integer check ("away_possession" >= 0), "home_shots" integer check ("home_shots" >= 0), "away_shots" integer check ("away_shots" >= 0), "home_on_target" integer check ("home_on_target" >= 0), "away_on_target" integer check ("away_on_target" >= 0), "home_corners" integer check ("home_corners" >= 0), "away_corners" integer check ("away_corners" >= 0), "notes" text, "round_id" text not null check (length(trim("round_id")) > 0), tournament_id text);
create table public.events (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "match_id" text not null check (length(trim("match_id")) > 0), "club_id" text not null check (length(trim("club_id")) > 0), "player_id" text, "assist_id" text, "type" text not null check (length(trim("type")) > 0) check ("type" in ('Gol','Gol contra','Cartão amarelo','Cartão vermelho','Substituição','Defesa','Destaque')), "minute" integer not null check ("minute" >= 0), "notes" text);
create table public.appearances (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "match_id" text not null check (length(trim("match_id")) > 0), "club_id" text not null check (length(trim("club_id")) > 0), "player_id" text not null check (length(trim("player_id")) > 0), "rating" numeric check ("rating" >= 0), "starter" text not null check (length(trim("starter")) > 0) check ("starter" in ('Sim','Não')));
create table public.news (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "title" text not null check (length(trim("title")) > 0), "summary" text not null check (length(trim("summary")) > 0), "body" text not null check (length(trim("body")) > 0), "image" text check ("image" is null or "image" ~ '^https://'), "category" text not null check (length(trim("category")) > 0) check ("category" in ('Transferências','Resultados','Bastidores','Entrevistas','Mercado da Bola','Comunicados')), "author" text not null check (length(trim("author")) > 0), "status" text not null check (length(trim("status")) > 0) check ("status" in ('Rascunho','Publicado')), "featured" text check ("featured" in ('Não','Sim')), "club_id" text, "player_id" text, "match_id" text, "video" text check ("video" is null or "video" ~ '^https://'));
create table public.videos (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "title" text not null check (length(trim("title")) > 0), "url" text not null check (length(trim("url")) > 0) check ("url" is null or "url" ~ '^https://'), "image" text check ("image" is null or "image" ~ '^https://'), "category" text not null check (length(trim("category")) > 0) check ("category" in ('Golaços','Defesas','Melhores lances','Compilações')), "season_id" text, "match_id" text, "club_id" text, "player_id" text, "status" text not null check (length(trim("status")) > 0) check ("status" in ('Rascunho','Publicado')));
create table public.transfers (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "season_id" text not null check (length(trim("season_id")) > 0), "player_id" text not null check (length(trim("player_id")) > 0), "from_id" text, "to_id" text not null check (length(trim("to_id")) > 0), "value" numeric check ("value" >= 0), "date" text not null check (length(trim("date")) > 0), "status" text not null check (length(trim("status")) > 0) check ("status" in ('Em negociação','Confirmada')), "news_id" text);
create table public.titles (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "season_id" text not null check (length(trim("season_id")) > 0), "club_id" text not null check (length(trim("club_id")) > 0), "runner_id" text, "name" text not null check (length(trim("name")) > 0), "image" text check ("image" is null or "image" ~ '^https://'), "story" text);
create table public.awards (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "season_id" text not null check (length(trim("season_id")) > 0), "name" text not null check (length(trim("name")) > 0) check ("name" in ('Craque da rodada','Seleção da rodada','Melhor jogador','Artilheiro','Melhor goleiro','Melhor técnico','Bola de Ouro','Hall da Fama','Recorde')), "player_id" text, "club_id" text, "round" integer check ("round" >= 0), "description" text, "image" text check ("image" is null or "image" ~ '^https://'));
create table public.sponsors (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "name" text not null check (length(trim("name")) > 0), "image" text not null check (length(trim("image")) > 0) check ("image" is null or "image" ~ '^https://'), "url" text check ("url" is null or "url" ~ '^https://'));
create table public.banners (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "title" text not null check (length(trim("title")) > 0), "description" text, "image" text check ("image" is null or "image" ~ '^https://'), "url" text, "status" text not null check (length(trim("status")) > 0) check ("status" in ('Publicado','Rascunho')));
create table public.phases (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "season_id" text not null check (length(trim("season_id")) > 0), "name" text not null check (length(trim("name")) > 0));
create table public.rounds (id text primary key default gen_random_uuid()::text, source text not null default 'local' check(source in ('local','copafacil')), created_at text not null default now()::text, updated_at text not null default now()::text, "phase_id" text not null check (length(trim("phase_id")) > 0), "number" integer not null check ("number" >= 0), "name" text not null check (length(trim("name")) > 0));
alter table public.memberships add foreign key ("season_id") references public.seasons(id);
alter table public.memberships add foreign key ("club_id") references public.clubs(id);
alter table public.memberships add foreign key ("player_id") references public.players(id);
alter table public.matches add foreign key ("season_id") references public.seasons(id);
alter table public.matches add foreign key ("home_id") references public.clubs(id);
alter table public.matches add foreign key ("away_id") references public.clubs(id);
alter table public.matches add foreign key ("round_id") references public.rounds(id);
alter table public.events add foreign key ("match_id") references public.matches(id);
alter table public.events add foreign key ("club_id") references public.clubs(id);
alter table public.events add foreign key ("player_id") references public.players(id);
alter table public.events add foreign key ("assist_id") references public.players(id);
alter table public.appearances add foreign key ("match_id") references public.matches(id);
alter table public.appearances add foreign key ("club_id") references public.clubs(id);
alter table public.appearances add foreign key ("player_id") references public.players(id);
alter table public.news add foreign key ("club_id") references public.clubs(id);
alter table public.news add foreign key ("player_id") references public.players(id);
alter table public.news add foreign key ("match_id") references public.matches(id);
alter table public.videos add foreign key ("season_id") references public.seasons(id);
alter table public.videos add foreign key ("match_id") references public.matches(id);
alter table public.videos add foreign key ("club_id") references public.clubs(id);
alter table public.videos add foreign key ("player_id") references public.players(id);
alter table public.transfers add foreign key ("season_id") references public.seasons(id);
alter table public.transfers add foreign key ("player_id") references public.players(id);
alter table public.transfers add foreign key ("from_id") references public.clubs(id);
alter table public.transfers add foreign key ("to_id") references public.clubs(id);
alter table public.transfers add foreign key ("news_id") references public.news(id);
alter table public.titles add foreign key ("season_id") references public.seasons(id);
alter table public.titles add foreign key ("club_id") references public.clubs(id);
alter table public.titles add foreign key ("runner_id") references public.clubs(id);
alter table public.awards add foreign key ("season_id") references public.seasons(id);
alter table public.awards add foreign key ("player_id") references public.players(id);
alter table public.awards add foreign key ("club_id") references public.clubs(id);
alter table public.phases add foreign key ("season_id") references public.seasons(id);
alter table public.rounds add foreign key ("phase_id") references public.phases(id);
create table public.members (id uuid primary key references auth.users(id) on delete cascade, email text not null, role text not null check(role in ('admin','editor')));
create table public.audit (id text primary key default gen_random_uuid()::text, actor text not null, action text not null, entity text not null, record_id text, created_at text not null default now()::text);
create table public.settings(id text primary key, value jsonb not null);
create table public.external(id text primary key, kind text not null, data jsonb not null, updated_at text not null default now()::text, season_id text references public.seasons(id), tournament_id text);
create table public.sync_runs(id text primary key default gen_random_uuid()::text,status text not null,message text not null,created_at text not null default now()::text);
create table private.integration (id boolean primary key default true check(id), api_key text, lease_until timestamptz, lease_id uuid);
insert into private.integration(id) values(true);
create function public.liga_role() returns text language sql stable security definer set search_path='' as $$ select role from public.members where id=auth.uid() $$;
revoke all on function public.liga_role() from public;
grant execute on function public.liga_role() to anon,authenticated;
alter table public.seasons enable row level security;
grant select on public.seasons to anon,authenticated;
grant insert,update,delete on public.seasons to authenticated;
create policy read_seasons on public.seasons for select using (true);
create policy write_seasons on public.seasons for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.clubs enable row level security;
grant select on public.clubs to anon,authenticated;
grant insert,update,delete on public.clubs to authenticated;
create policy read_clubs on public.clubs for select using (true);
create policy write_clubs on public.clubs for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.players enable row level security;
grant select on public.players to anon,authenticated;
grant insert,update,delete on public.players to authenticated;
create policy read_players on public.players for select using (true);
create policy write_players on public.players for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.memberships enable row level security;
grant select on public.memberships to anon,authenticated;
grant insert,update,delete on public.memberships to authenticated;
create policy read_memberships on public.memberships for select using (true);
create policy write_memberships on public.memberships for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.matches enable row level security;
grant select on public.matches to anon,authenticated;
grant insert,update,delete on public.matches to authenticated;
create policy read_matches on public.matches for select using (true);
create policy write_matches on public.matches for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.events enable row level security;
grant select on public.events to anon,authenticated;
grant insert,update,delete on public.events to authenticated;
create policy read_events on public.events for select using (true);
create policy write_events on public.events for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.appearances enable row level security;
grant select on public.appearances to anon,authenticated;
grant insert,update,delete on public.appearances to authenticated;
create policy read_appearances on public.appearances for select using (true);
create policy write_appearances on public.appearances for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.news enable row level security;
grant select on public.news to anon,authenticated;
grant insert,update,delete on public.news to authenticated;
create policy read_news on public.news for select using (status='Publicado' or public.liga_role() in ('admin','editor'));
create policy write_news on public.news for all to authenticated using (public.liga_role() in ('admin','editor') and source='local') with check (public.liga_role() in ('admin','editor') and source='local');
alter table public.videos enable row level security;
grant select on public.videos to anon,authenticated;
grant insert,update,delete on public.videos to authenticated;
create policy read_videos on public.videos for select using (status='Publicado' or public.liga_role() in ('admin','editor'));
create policy write_videos on public.videos for all to authenticated using (public.liga_role() in ('admin','editor') and source='local') with check (public.liga_role() in ('admin','editor') and source='local');
alter table public.transfers enable row level security;
grant select on public.transfers to anon,authenticated;
grant insert,update,delete on public.transfers to authenticated;
create policy read_transfers on public.transfers for select using (true);
create policy write_transfers on public.transfers for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.titles enable row level security;
grant select on public.titles to anon,authenticated;
grant insert,update,delete on public.titles to authenticated;
create policy read_titles on public.titles for select using (true);
create policy write_titles on public.titles for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.awards enable row level security;
grant select on public.awards to anon,authenticated;
grant insert,update,delete on public.awards to authenticated;
create policy read_awards on public.awards for select using (true);
create policy write_awards on public.awards for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.sponsors enable row level security;
grant select on public.sponsors to anon,authenticated;
grant insert,update,delete on public.sponsors to authenticated;
create policy read_sponsors on public.sponsors for select using (true);
create policy write_sponsors on public.sponsors for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.banners enable row level security;
grant select on public.banners to anon,authenticated;
grant insert,update,delete on public.banners to authenticated;
create policy read_banners on public.banners for select using (status='Publicado' or public.liga_role() in ('admin','editor'));
create policy write_banners on public.banners for all to authenticated using (public.liga_role() in ('admin','editor') and source='local') with check (public.liga_role() in ('admin','editor') and source='local');
alter table public.phases enable row level security;
grant select on public.phases to anon,authenticated;
grant insert,update,delete on public.phases to authenticated;
create policy read_phases on public.phases for select using (true);
create policy write_phases on public.phases for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.rounds enable row level security;
grant select on public.rounds to anon,authenticated;
grant insert,update,delete on public.rounds to authenticated;
create policy read_rounds on public.rounds for select using (true);
create policy write_rounds on public.rounds for all to authenticated using (public.liga_role() = 'admin' and source='local') with check (public.liga_role() = 'admin' and source='local');
alter table public.members enable row level security;
grant select on public.members to authenticated;
create policy read_members on public.members for select to authenticated using (id=auth.uid() or public.liga_role()='admin');
alter table public.audit enable row level security;
grant select on public.audit to authenticated;
create policy read_audit on public.audit for select to authenticated using (public.liga_role()='admin');
alter table public.sync_runs enable row level security;
grant select on public.sync_runs to authenticated;
create policy read_sync_runs on public.sync_runs for select to authenticated using (public.liga_role()='admin');
alter table public.settings enable row level security;
grant select on public.settings to authenticated;
create policy read_settings on public.settings for select to authenticated using (true);
alter table public.external enable row level security;
grant select on public.external to authenticated;
create policy read_external on public.external for select to authenticated using (true);
grant select on public.settings,public.external to anon;
create policy public_settings on public.settings for select to anon using(id='integration');
create policy public_external on public.external for select to anon using(kind in ('table','ranking','matches'));
revoke insert,update,delete on public.members,public.audit,public.settings,public.external,public.sync_runs from anon,authenticated;
create unique index active_membership_unique on public.memberships(player_id,season_id) where ended is null;
create unique index appearance_unique on public.appearances(match_id,player_id);
create unique index round_unique on public.rounds(phase_id,number);
alter table public.matches add check(home_id<>away_id), add check(status<>'Encerrado' or (home_score is not null and away_score is not null)), add check(home_possession<=100 and away_possession<=100);
alter table public.events add check(assist_id is null or (type='Gol' and player_id is not null and assist_id<>player_id)), add check(type not in ('Gol','Gol contra') or player_id is not null), add check(minute<=150);
alter table public.appearances add check(rating<=10);
alter table public.players add check(overall<=110);
alter table public.transfers add check(from_id is distinct from to_id);
alter table public.banners add check(url is null or url ~ '^https://' or url ~ '^/[^/]');
create function private.audit_change() returns trigger language plpgsql security definer set search_path='' as $$ begin
 insert into public.audit(actor,action,entity,record_id) values(coalesce(auth.uid()::text,'sistema'),TG_OP,TG_TABLE_NAME,coalesce(new.id,old.id)::text); return coalesce(new,old); end $$;
create function private.touch_record() returns trigger language plpgsql set search_path='' as $$ begin new.updated_at=now()::text; return new; end $$;
create trigger log_change after insert or update or delete on public.seasons for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.clubs for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.players for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.memberships for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.matches for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.events for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.appearances for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.news for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.videos for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.transfers for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.titles for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.awards for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.sponsors for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.banners for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.phases for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.rounds for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.members for each row execute function private.audit_change();
create trigger log_change after insert or update or delete on public.settings for each row execute function private.audit_change();
create trigger touch_record before update on public.seasons for each row execute function private.touch_record();
create trigger touch_record before update on public.clubs for each row execute function private.touch_record();
create trigger touch_record before update on public.players for each row execute function private.touch_record();
create trigger touch_record before update on public.memberships for each row execute function private.touch_record();
create trigger touch_record before update on public.matches for each row execute function private.touch_record();
create trigger touch_record before update on public.events for each row execute function private.touch_record();
create trigger touch_record before update on public.appearances for each row execute function private.touch_record();
create trigger touch_record before update on public.news for each row execute function private.touch_record();
create trigger touch_record before update on public.videos for each row execute function private.touch_record();
create trigger touch_record before update on public.transfers for each row execute function private.touch_record();
create trigger touch_record before update on public.titles for each row execute function private.touch_record();
create trigger touch_record before update on public.awards for each row execute function private.touch_record();
create trigger touch_record before update on public.sponsors for each row execute function private.touch_record();
create trigger touch_record before update on public.banners for each row execute function private.touch_record();
create trigger touch_record before update on public.phases for each row execute function private.touch_record();
create trigger touch_record before update on public.rounds for each row execute function private.touch_record();
create function private.match_round() returns trigger language plpgsql set search_path='' as $$ declare r record; begin
 select rounds.number,phases.name,phases.season_id into r from public.rounds join public.phases on phases.id=rounds.phase_id where rounds.id=new.round_id;
 if r.season_id is distinct from new.season_id then raise exception 'A rodada deve pertencer à temporada da partida.'; end if;
 new.round=r.number;new.phase=r.name;return new;end $$;
create trigger match_round before insert or update on public.matches for each row execute function private.match_round();
create function private.event_team() returns trigger language plpgsql set search_path='' as $$ declare m public.matches; p text; begin
 select * into m from public.matches where id=new.match_id;
 if new.club_id not in (m.home_id,m.away_id) then raise exception 'O clube não participa desta partida.'; end if;
 for p in select v from (values(new.player_id),(case when TG_TABLE_NAME='events' then to_jsonb(new)->>'assist_id' else null end)) as x(v) where v is not null loop
 if not exists(select 1 from public.memberships where player_id=p and season_id=m.season_id and club_id=new.club_id and (m.kickoff is null or ((started is null or started<=left(m.kickoff,10)) and (ended is null or ended>=left(m.kickoff,10))))) then raise exception 'Jogador sem vínculo com este clube na temporada/data da partida.'; end if;
 end loop; return new;end $$;
create trigger event_team before insert or update on public.events for each row execute function private.event_team();
create trigger appearance_team before insert or update on public.appearances for each row execute function private.event_team();
create function private.transfer_player() returns trigger language plpgsql set search_path='' as $$ declare current_link public.memberships; begin
 if TG_OP<>'INSERT' and old.status='Confirmada' then raise exception 'Transferência confirmada é histórica. Cadastre uma nova negociação.'; end if;
 if TG_OP='DELETE' then return old;end if;
 if new.status='Confirmada' then
 perform 1 from public.players where id=new.player_id for update;
 select * into current_link from public.memberships where player_id=new.player_id and season_id=new.season_id and ended is null for update;
 if current_link.club_id is distinct from new.from_id then raise exception 'Clube de origem difere do vínculo ativo.';end if;
 if current_link.started>new.date then raise exception 'Transferência anterior ao início do vínculo.';end if;
 update public.memberships set ended=new.date where id=current_link.id;
 insert into public.memberships(id,season_id,club_id,player_id,role,started) values('transfer:'||new.id,new.season_id,new.to_id,new.player_id,'Reserva',new.date);
 end if;return new;end $$;
create trigger transfer_player before insert or update or delete on public.transfers for each row execute function private.transfer_player();
-- Só o proprietário do projeto, pelo SQL Editor, concede a primeira permissão.
create function public.authorize_member(member_email text, member_role text) returns void language plpgsql security definer set search_path='' as $$ declare target uuid;begin
 if public.liga_role() is distinct from 'admin' then raise exception 'Acesso negado';end if;
 select id into target from auth.users where lower(email)=lower(trim(member_email)) and email_confirmed_at is not null;
 if target is null then raise exception 'Crie/confirme a conta no Supabase Auth antes de autorizar.';end if;
 if target=auth.uid() then raise exception 'Não altere sua própria permissão.';end if;
 insert into public.members(id,email,role) values(target,lower(trim(member_email)),member_role) on conflict(id) do update set role=excluded.role;
 end $$;
create function public.remove_member(member_id uuid) returns void language plpgsql security definer set search_path='' as $$ begin
 if public.liga_role() is distinct from 'admin' or member_id=auth.uid() then raise exception 'Acesso negado';end if;
 delete from public.members where id=member_id;end $$;
revoke all on function public.authorize_member(text,text),public.remove_member(uuid) from public;
grant execute on function public.authorize_member(text,text),public.remove_member(uuid) to authenticated;
insert into public.settings(id,value) values('integration','{"mode":"local","enabled":false,"interval":15,"modules":["stages","table","matches","rankings","teams","players"]}');
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('liga-images','liga-images',true,5242880,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy images_read on storage.objects for select using(bucket_id='liga-images');
create policy images_insert on storage.objects for insert to authenticated with check(bucket_id='liga-images' and public.liga_role() in ('admin','editor'));
create policy images_delete on storage.objects for delete to authenticated using(bucket_id='liga-images' and public.liga_role()='admin');
insert into public.clubs(id,name,short,manager,color) values('cruzeiro','Cruzeiro','CRU','Sazon','#174cba') on conflict(id) do nothing;
insert into public.clubs(id,name,short,manager,color) values('flamengo','Flamengo','FLA','Mateus','#c52532') on conflict(id) do nothing;
insert into public.clubs(id,name,short,manager,color) values('sao-paulo','São Paulo','SAO','Swit','#d82230') on conflict(id) do nothing;
insert into public.clubs(id,name,short,manager,color) values('santos','Santos','SAN','Paiiva','#333333') on conflict(id) do nothing;
insert into public.clubs(id,name,short,manager,color) values('palmeiras','Palmeiras','PAL','Jade','#087650') on conflict(id) do nothing;
insert into public.clubs(id,name,short,manager,color) values('corinthians','Corinthians','COR','Gusta','#222222') on conflict(id) do nothing;
-- Phase/round edits stay consistent with already registered matches.
create function private.refresh_round_matches() returns trigger language plpgsql set search_path='' as $$ begin
 if new.phase_id<>old.phase_id then raise exception 'Para mudar a fase, cadastre outra rodada.';end if;
 update public.matches set round=new.number where round_id=new.id;return new;end $$;
create trigger refresh_round_matches after update on public.rounds for each row execute function private.refresh_round_matches();
create function private.refresh_phase_matches() returns trigger language plpgsql set search_path='' as $$ begin
 if new.season_id<>old.season_id then raise exception 'Para mudar a temporada, cadastre outra fase.';end if;
 update public.matches set phase=new.name where round_id in (select id from public.rounds where phase_id=new.id);return new;end $$;
create trigger refresh_phase_matches after update on public.phases for each row execute function private.refresh_phase_matches();
create function private.protect_match_context() returns trigger language plpgsql set search_path='' as $$ begin
 if (new.season_id,new.home_id,new.away_id) is distinct from (old.season_id,old.home_id,old.away_id)
 and (exists(select 1 from public.events where match_id=old.id) or exists(select 1 from public.appearances where match_id=old.id)) then raise exception 'Remova ou corrija os lances e participações antes de mudar os clubes/temporada.';end if;
 return new;end $$;
create trigger protect_match_context before update on public.matches for each row execute function private.protect_match_context();
grant all on all tables in schema public to service_role;
commit;

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

-- Cadastro de elencos com informações parciais
-- Elencos podem ser cadastrados antes de conhecer posição ou titularidade.
alter table public.players alter column position drop not null;
alter table public.players drop constraint players_position_check1;
alter table public.players add constraint players_position_check1
check (position in ('GOL','ZAG','LD','LE','VOL','MC','MEI','PD','PE','SA','CA','Ponta','Lateral','Ala','Atacante'));
alter table public.memberships alter column role drop not null;
