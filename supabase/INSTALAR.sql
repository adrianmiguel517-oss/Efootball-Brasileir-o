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

-- Totais publicados da temporada, sem inventar eventos de partidas.
create table public.player_totals (
 id text primary key default gen_random_uuid()::text,
 source text not null default 'local' check(source='local'),
 season_id text not null references public.seasons(id),
 club_id text not null references public.clubs(id),
 player_id text not null references public.players(id),
 goals integer not null check(goals>=0),
 assists integer not null check(assists>=0),
 notes text,
 created_at text not null default now()::text,
 updated_at text not null default now()::text,
 unique(season_id,player_id)
);
create index player_totals_club_idx on public.player_totals(club_id);
create index player_totals_player_idx on public.player_totals(player_id);
alter table public.player_totals enable row level security;
revoke all on public.player_totals from anon,authenticated;
grant select on public.player_totals to anon,authenticated;
grant insert,update,delete on public.player_totals to authenticated;
create policy read_player_totals on public.player_totals for select using(true);
create policy write_player_totals on public.player_totals for all to authenticated
using(public.liga_role()='admin')
with check(public.liga_role()='admin' and exists(
select 1 from public.memberships m where m.player_id=player_totals.player_id
and m.club_id=player_totals.club_id and m.season_id=player_totals.season_id));
create trigger log_change after insert or update or delete on public.player_totals for each row execute function private.audit_change();
create trigger touch_record before update on public.player_totals for each row execute function private.touch_record();
comment on table public.player_totals is 'Totais oficiais da temporada. Enquanto existir registro, gols e assistências substituem o cálculo por lances; nunca são somados a ele. Excluir o total somente depois de conferir os eventos completos.';

-- Identifica o formato da fase para preservar a classificação de pontos corridos.
alter table public.phases add column format text not null default 'Pontos corridos' check(format in ('Pontos corridos','Eliminatória'));

-- A importação Copa Fácil usa registros JSON parciais; ausência de formato mantém pontos corridos.
alter table public.phases alter column format drop not null;

-- Carteira da liga: unidades em milhões VIRTUAIS; não processa dinheiro real.
create table public.bet_wallets(id text primary key default gen_random_uuid()::text,season_id text not null references public.seasons(id),club_id text not null references public.clubs(id),owner_id uuid references auth.users(id),balance numeric(16,2) not null default 15 check(balance>=0),created_at timestamptz not null default now(),unique(season_id,club_id),unique(season_id,owner_id));
create index bet_wallet_owner on public.bet_wallets(owner_id);
create index bet_wallet_club on public.bet_wallets(club_id);
create table public.bet_markets(id text primary key references public.matches(id),state text not null default 'closed' check(state in('open','closed','settled','void')),home_odds numeric(8,2) not null check(home_odds>=1),draw_odds numeric(8,2) not null check(draw_odds>=1),away_odds numeric(8,2) not null check(away_odds>=1),closes_at timestamptz,settled_home integer,settled_away integer,created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table public.bet_tickets(id text primary key default gen_random_uuid()::text,wallet_id text not null references public.bet_wallets(id),match_id text not null references public.bet_markets(id),actor_id uuid not null references auth.users(id),request_id uuid not null,choice text not null check(choice in('H','D','A')),stake numeric(16,2) not null check(stake>=0.01),odds numeric(8,2) not null check(odds>=1),potential numeric(16,2) not null check(potential>=stake),paid numeric(16,2) not null default 0 check(paid>=0),status text not null default 'pending' check(status in('pending','won','lost','void')),created_at timestamptz not null default now(),unique(actor_id,request_id));
create index bet_tickets_wallet on public.bet_tickets(wallet_id);
create index bet_tickets_match on public.bet_tickets(match_id);
create table public.bet_withdrawals(id text primary key default gen_random_uuid()::text,wallet_id text not null references public.bet_wallets(id),actor_id uuid not null references auth.users(id),request_id uuid not null,amount numeric(16,2) not null check(amount>0),status text not null default 'pending' check(status in('pending','approved','rejected')),note text,created_at timestamptz not null default now(),unique(actor_id,request_id));
create index bet_withdrawals_wallet on public.bet_withdrawals(wallet_id);
create table public.bet_ledger(id text primary key default gen_random_uuid()::text,wallet_id text not null references public.bet_wallets(id),event_key text not null unique,kind text not null,amount numeric(16,2) not null check(amount<>0),balance_after numeric(16,2) not null check(balance_after>=0),created_at timestamptz not null default now());
create index bet_ledger_wallet on public.bet_ledger(wallet_id,created_at);
-- Somente RPCs autenticadas movimentam saldo. Nem administradores editam o saldo diretamente.
revoke all on public.bet_wallets,public.bet_markets,public.bet_tickets,public.bet_withdrawals,public.bet_ledger from anon,authenticated;
alter table public.bet_wallets enable row level security;alter table public.bet_markets enable row level security;alter table public.bet_tickets enable row level security;alter table public.bet_withdrawals enable row level security;alter table public.bet_ledger enable row level security;
grant select on public.bet_markets to anon,authenticated;
create policy bet_market_read on public.bet_markets for select using(true);
grant select on public.bet_wallets,public.bet_tickets,public.bet_withdrawals,public.bet_ledger to authenticated;
create policy bet_wallet_read on public.bet_wallets for select to authenticated using(owner_id=(select auth.uid()) or (select public.liga_role())='admin');
create policy bet_ticket_read on public.bet_tickets for select to authenticated using(exists(select 1 from public.bet_wallets w where w.id=wallet_id));
create policy bet_withdrawal_read on public.bet_withdrawals for select to authenticated using(exists(select 1 from public.bet_wallets w where w.id=wallet_id));
create policy bet_ledger_read on public.bet_ledger for select to authenticated using(exists(select 1 from public.bet_wallets w where w.id=wallet_id));
create trigger bet_wallet_log after insert or update or delete on public.bet_wallets for each row execute function private.audit_change();
create trigger bet_market_log after insert or update or delete on public.bet_markets for each row execute function private.audit_change();
create trigger bet_ticket_log after insert or update or delete on public.bet_tickets for each row execute function private.audit_change();
create trigger bet_withdrawal_log after insert or update or delete on public.bet_withdrawals for each row execute function private.audit_change();
create function private.bet_quote(match_key text) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare m public.matches; base numeric; ha numeric; hd numeric; aa numeric; ad numeric; hj integer; aj integer; hp numeric; ap numeric; hx numeric; ax numeric; ph numeric; pd numeric; pa numeric; total numeric;
begin
select * into strict m from public.matches where id=match_key;
select coalesce(avg((home_score+away_score)/2.0),2.0) into base from public.matches where season_id=m.season_id and status='Encerrado' and id<>m.id;
base:=greatest(0.6,base);
select count(*),coalesce(sum(case when home_id=m.home_id then home_score else away_score end),0),coalesce(sum(case when home_id=m.home_id then away_score else home_score end),0),coalesce(sum(case when (home_id=m.home_id and home_score>away_score) or (away_id=m.home_id and away_score>home_score) then 3 when home_score=away_score then 1 else 0 end),0) into hj,ha,hd,hp from public.matches where season_id=m.season_id and status='Encerrado' and id<>m.id and m.home_id in(home_id,away_id);
select count(*),coalesce(sum(case when home_id=m.away_id then home_score else away_score end),0),coalesce(sum(case when home_id=m.away_id then away_score else home_score end),0),coalesce(sum(case when (home_id=m.away_id and home_score>away_score) or (away_id=m.away_id and away_score>home_score) then 3 when home_score=away_score then 1 else 0 end),0) into aj,aa,ad,ap from public.matches where season_id=m.season_id and status='Encerrado' and id<>m.id and m.away_id in(home_id,away_id);
-- Suavização de três jogos para clubes sem histórico; força pelo aproveitamento e gols.
hx:=least(5.0,greatest(0.25,((ha+base*3)/(hj+3))*((ad+base*3)/(aj+3))/base*(0.85+0.3*(hp+4.5)/(3*hj+9))));
ax:=least(5.0,greatest(0.25,((aa+base*3)/(aj+3))*((hd+base*3)/(hj+3))/base*(0.85+0.3*(ap+4.5)/(3*aj+9))));
select sum(p) filter(where i>j),sum(p) filter(where i=j),sum(p) filter(where i<j) into ph,pd,pa from(select i,j,exp(-hx)*power(hx,i)/factorial(i)*exp(-ax)*power(ax,j)/factorial(j) as p from generate_series(0,12) i cross join generate_series(0,12) j) q;
total:=ph+pd+pa;return jsonb_build_object('home',least(20,greatest(1.05,round(0.94/(ph/total),2))),'draw',least(20,greatest(1.05,round(0.94/(pd/total),2))),'away',least(20,greatest(1.05,round(0.94/(pa/total),2))),'model','Campanha e gols · Poisson v1 · margem virtual de 6%');
end $$;
create function private.bet_state(season_key text) returns jsonb language plpgsql stable security definer set search_path='' as $$
declare u uuid:=auth.uid();adm boolean:=coalesce(public.liga_role()='admin',false);w public.bet_wallets;
begin
select * into w from public.bet_wallets where season_id=season_key and owner_id=u;
return jsonb_build_object('wallet',case when w.id is not null then to_jsonb(w) else null end,'admin',adm,
'markets',(select coalesce(jsonb_agg(jsonb_build_object('match_id',m.id,'state',coalesce(b.state,'closed'),'closes_at',b.closes_at,'odds',case when b.id is not null then jsonb_build_object('home',b.home_odds,'draw',b.draw_odds,'away',b.away_odds) when m.status='Agendado' then private.bet_quote(m.id) else null end) order by m.phase,m.round,m.id),'[]') from public.matches m left join public.bet_markets b on b.id=m.id where m.season_id=season_key),
'leaderboard',(select coalesce(jsonb_agg(jsonb_build_object('club_id',x.club_id,'balance',x.balance) order by x.balance desc),'[]') from public.bet_wallets x where x.season_id=season_key),
'wallets',case when adm then (select coalesce(jsonb_agg(jsonb_build_object('id',x.id,'club_id',x.club_id,'balance',x.balance,'email',a.email)),'[]') from public.bet_wallets x left join auth.users a on a.id=x.owner_id where x.season_id=season_key) else '[]' end,
 'tickets',(select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at desc),'[]') from public.bet_tickets t join public.bet_wallets x on x.id=t.wallet_id where x.season_id=season_key and (adm or x.owner_id=u)),
 'withdrawals',(select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at desc),'[]') from public.bet_withdrawals t join public.bet_wallets x on x.id=t.wallet_id where x.season_id=season_key and (adm or x.owner_id=u)),
 'ledger',(select coalesce(jsonb_agg(to_jsonb(t) order by t.created_at desc),'[]') from public.bet_ledger t where t.wallet_id=w.id));end $$;
create function private.bet_place(match_key text,pick text,amount numeric,expected_odds numeric,request_key uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=auth.uid();m public.matches;b public.bet_markets;w public.bet_wallets;t public.bet_tickets;o numeric;newbal numeric;
begin
if u is null then raise exception 'Entre na sua conta';end if;
select * into t from public.bet_tickets where actor_id=u and request_id=request_key;
if found then if t.match_id<>match_key or t.choice<>pick or t.stake<>amount then raise exception 'Identificador já usado';end if;return to_jsonb(t);end if;
if request_key is null or pick not in('H','D','A') or pick is null or amount is null or amount<0.01 or amount<>round(amount,2) then raise exception 'Aposta inválida';end if;
select * into strict m from public.matches where id=match_key for update;
select * into strict b from public.bet_markets where id=match_key for update;
if m.status<>'Agendado' or b.state<>'open' or b.closes_at is null or b.closes_at<=now() or (m.kickoff is not null and m.kickoff::timestamptz<=now()) or not exists(select 1 from public.seasons where id=m.season_id and status='Em andamento') then raise exception 'Apostas encerradas para este jogo';end if;
select * into strict w from public.bet_wallets where season_id=m.season_id and owner_id=u for update;
-- Outra chamada pode ter concluído enquanto esta aguardava o lock.
select * into t from public.bet_tickets where actor_id=u and request_id=request_key;if found then if t.match_id<>match_key or t.choice<>pick or t.stake<>amount then raise exception 'Identificador já usado';end if;return to_jsonb(t);end if;
o:=case pick when 'H' then b.home_odds when 'D' then b.draw_odds else b.away_odds end;
if expected_odds is null or o<>expected_odds then raise exception 'As odds mudaram. Selecione novamente';end if;
if w.balance<amount then raise exception 'Saldo virtual insuficiente';end if;
update public.bet_wallets set balance=balance-amount where id=w.id returning balance into newbal;
insert into public.bet_tickets(wallet_id,match_id,actor_id,request_id,choice,stake,odds,potential) values(w.id,m.id,u,request_key,pick,amount,o,round(amount*o,2)) returning * into t;
insert into public.bet_ledger(wallet_id,event_key,kind,amount,balance_after) values(w.id,'stake:'||t.id,'Aposta',-amount,newbal);return to_jsonb(t);end $$;
create function private.bet_withdraw(season_key text,amount numeric,request_key uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=auth.uid();w public.bet_wallets;r public.bet_withdrawals;bal numeric;
begin
if u is null then raise exception 'Entre na sua conta';end if;
select * into strict w from public.bet_wallets where season_id=season_key and owner_id=u for update;
select * into r from public.bet_withdrawals where actor_id=u and request_id=request_key;if found then if r.wallet_id<>w.id or r.amount<>amount then raise exception 'Identificador já usado';end if;return to_jsonb(r);end if;
if request_key is null or amount is null or amount<=0 or amount<>round(amount,2) or w.balance<30 or amount>w.balance then raise exception 'Retirada exige saldo disponível de pelo menos 30 Mi e valor dentro do saldo';end if;
update public.bet_wallets set balance=balance-amount where id=w.id returning balance into bal;
insert into public.bet_withdrawals(wallet_id,actor_id,request_id,amount) values(w.id,u,request_key,amount) returning * into r;
insert into public.bet_ledger(wallet_id,event_key,kind,amount,balance_after) values(w.id,'withdraw:'||r.id,'Retirada reservada',-amount,bal);return to_jsonb(r);end $$;
create function private.bet_admin(action_name text,payload jsonb) returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=auth.uid();sid text:=payload->>'season_id';mid text:=payload->>'match_id';m public.matches;b public.bet_markets;w public.bet_wallets;t public.bet_tickets;r public.bet_withdrawals;q jsonb;owner_key uuid;bal numeric;paid_amount numeric;outcome text;deadline timestamptz;n integer:=0;ret text;
begin
if u is null or public.liga_role() is distinct from 'admin' then raise exception 'Somente o administrador';end if;
if action_name='initialize' then
if not exists(select 1 from public.seasons where id=sid and status='Em andamento') then raise exception 'Temporada não está em andamento';end if;
for w in insert into public.bet_wallets(season_id,club_id) select sid,id from public.clubs where source='local' on conflict(season_id,club_id) do nothing returning * loop
insert into public.bet_ledger(wallet_id,event_key,kind,amount,balance_after) values(w.id,'initial:'||w.id,'Crédito único da temporada',15,15);n:=n+1;end loop;
return jsonb_build_object('created',n);
elsif action_name='assign' then
select id into owner_key from auth.users where lower(email)=lower(trim(payload->>'email')) and email_confirmed_at is not null;if owner_key is null then raise exception 'O responsável precisa criar a conta e confirmar o e-mail primeiro';end if;
select * into strict w from public.bet_wallets where season_id=sid and club_id=payload->>'club_id' for update;
update public.bet_wallets set owner_id=owner_key where id=w.id;return jsonb_build_object('ok',true);
elsif action_name in('approve','reject') then
select * into strict r from public.bet_withdrawals where id=payload->>'withdrawal_id' for update;
if r.status<>'pending' then return jsonb_build_object('status',r.status);end if;
if length(trim(coalesce(payload->>'note','')))<3 then raise exception 'Registre a referência do crédito virtual ou motivo';end if;
select * into strict w from public.bet_wallets where id=r.wallet_id for update;
if action_name='reject' then update public.bet_wallets set balance=balance+r.amount where id=w.id returning balance into bal;insert into public.bet_ledger(wallet_id,event_key,kind,amount,balance_after) values(w.id,'reject:'||r.id,'Retirada devolvida',r.amount,bal);end if;
update public.bet_withdrawals set status=case action_name when 'approve' then 'approved' else 'rejected' end,note=payload->>'note' where id=r.id;return jsonb_build_object('ok',true);
elsif action_name in('open','close','settle','void') then
select * into strict m from public.matches where id=mid for update;
select * into b from public.bet_markets where id=mid for update;
if action_name='open' then
if b.state in('settled','void') then raise exception 'Mercado já finalizado';end if;
if m.status<>'Agendado' or not exists(select 1 from public.seasons where id=m.season_id and status='Em andamento') then raise exception 'Abra somente jogos agendados da temporada em andamento';end if;
deadline:=(payload->>'closes_at')::timestamptz;if deadline is null or deadline<=now() or (m.kickoff is not null and deadline>m.kickoff::timestamptz) then raise exception 'Defina um encerramento futuro, até o início da partida';end if;
q:=private.bet_quote(mid);
insert into public.bet_markets(id,state,home_odds,draw_odds,away_odds,closes_at) values(mid,'open',(q->>'home')::numeric,(q->>'draw')::numeric,(q->>'away')::numeric,deadline) on conflict(id) do update set state='open',home_odds=excluded.home_odds,draw_odds=excluded.draw_odds,away_odds=excluded.away_odds,closes_at=deadline,updated_at=now();return q;
end if;
if b.id is null then raise exception 'Mercado não cadastrado';end if;
if b.state in('settled','void') then return jsonb_build_object('state',b.state);end if;
if action_name='close' then update public.bet_markets set state='closed',updated_at=now() where id=mid;return jsonb_build_object('ok',true);end if;
if action_name='settle' and (m.status<>'Encerrado' or m.home_score is null or m.away_score is null) then raise exception 'Confirme primeiro o placar encerrado da partida';end if;
outcome:=case when m.home_score>m.away_score then 'H' when m.home_score=m.away_score then 'D' else 'A' end;
for t in select * from public.bet_tickets where match_id=mid and status='pending' order by wallet_id,id for update loop
select * into strict w from public.bet_wallets where id=t.wallet_id for update;
paid_amount:=case when action_name='void' then t.stake when t.choice=outcome then t.potential else 0 end;
if paid_amount>0 then update public.bet_wallets set balance=balance+paid_amount where id=w.id returning balance into bal;insert into public.bet_ledger(wallet_id,event_key,kind,amount,balance_after) values(w.id,'pay:'||t.id,case when action_name='void' then 'Aposta devolvida' else 'Retorno da aposta' end,paid_amount,bal);end if;
update public.bet_tickets set paid=paid_amount,status=case when action_name='void' then 'void' when paid_amount>0 then 'won' else 'lost' end where id=t.id;n:=n+1;
end loop;
update public.bet_markets set state=case when action_name='void' then 'void' else 'settled' end,settled_home=case when action_name='settle' then m.home_score end,settled_away=case when action_name='settle' then m.away_score end,updated_at=now() where id=mid;
return jsonb_build_object('processed',n);
end if;raise exception 'Ação inválida';end $$;
create function private.bet_match_guard() returns trigger language plpgsql security definer set search_path='' as $$ begin
if exists(select 1 from public.bet_markets where id=old.id) and (new.home_id<>old.home_id or new.away_id<>old.away_id or new.season_id<>old.season_id) then raise exception 'Não altere os clubes ou temporada de um jogo com mercado cadastrado';end if;
if exists(select 1 from public.bet_markets where id=old.id and state='settled') and (new.home_score is distinct from old.home_score or new.away_score is distinct from old.away_score or new.status<>old.status) then raise exception 'Resultado já liquidado nas apostas. Requer reconciliação pela organização antes de corrigir';end if;
if new.status<>'Agendado' then update public.bet_markets set state='closed',updated_at=now() where id=old.id and state='open';end if;return new;end $$;
create trigger bet_match_guard before update on public.matches for each row execute function private.bet_match_guard();
-- API pública mínima: implementação privilegiada fica no schema privado.
create function public.bet_state(season_key text) returns jsonb language sql security invoker set search_path='' as $$select private.bet_state(season_key)$$;
create function public.bet_place(match_key text,pick text,amount numeric,expected_odds numeric,request_key uuid) returns jsonb language sql security invoker set search_path='' as $$select private.bet_place(match_key,pick,amount,expected_odds,request_key)$$;
create function public.bet_withdraw(season_key text,amount numeric,request_key uuid) returns jsonb language sql security invoker set search_path='' as $$select private.bet_withdraw(season_key,amount,request_key)$$;
create function public.bet_admin(action_name text,payload jsonb) returns jsonb language sql security invoker set search_path='' as $$select private.bet_admin(action_name,payload)$$;
revoke all on function private.bet_quote(text),private.bet_state(text),private.bet_place(text,text,numeric,numeric,uuid),private.bet_withdraw(text,numeric,uuid),private.bet_admin(text,jsonb),private.bet_match_guard() from public,anon,authenticated;
revoke all on function public.bet_state(text),public.bet_place(text,text,numeric,numeric,uuid),public.bet_withdraw(text,numeric,uuid),public.bet_admin(text,jsonb) from public,anon,authenticated;
grant execute on function public.bet_state(text),private.bet_state(text) to anon,authenticated;
grant execute on function public.bet_place(text,text,numeric,numeric,uuid),private.bet_place(text,text,numeric,numeric,uuid),public.bet_withdraw(text,numeric,uuid),private.bet_withdraw(text,numeric,uuid),public.bet_admin(text,jsonb),private.bet_admin(text,jsonb) to authenticated;

-- Comunicação dos clubes
-- Club communication uses the same verified, administrator-assigned club owner.
alter table public.news add column club_post boolean not null default false;
alter table public.news add constraint club_post_requires_club check(not club_post or club_id is not null);
create index news_club_publication on public.news(club_id,status);

create function public.club_news_access() returns setof text language sql stable security invoker set search_path='' as $$
 select distinct w.club_id from public.bet_wallets w join public.seasons s on s.id=w.season_id
 where w.owner_id=(select auth.uid()) and s.status='Em andamento'
$$;
create function public.can_publish_club(club_key text) returns boolean language sql stable security invoker set search_path='' as $$
 select exists(select 1 from public.club_news_access() c where c=club_key)
$$;
revoke all on function public.club_news_access(),public.can_publish_club(text) from public,anon,authenticated;
grant execute on function public.club_news_access(),public.can_publish_club(text) to authenticated;

create policy club_news_read on public.news for select to authenticated
 using(club_post and source='local' and public.can_publish_club(club_id));
create policy club_news_insert on public.news for insert to authenticated
 with check(club_post and source='local' and public.can_publish_club(club_id));
create policy club_news_update on public.news for update to authenticated
 using(club_post and source='local' and public.can_publish_club(club_id))
 with check(club_post and source='local' and public.can_publish_club(club_id));
create policy club_news_delete on public.news for delete to authenticated
 using(club_post and source='local' and public.can_publish_club(club_id));

create function private.guard_club_news() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if current_user in ('postgres','supabase_admin','service_role') or coalesce(private.liga_role() in ('admin','editor'),false) then return new; end if;
 if auth.uid() is null or not new.club_post or new.club_id is null or new.source<>'local' or not public.can_publish_club(new.club_id) then raise exception 'Você pode publicar somente na página do seu clube.'; end if;
 if tg_op='UPDATE' and row(new.id,new.club_id,new.source,new.created_at,new.club_post) is distinct from row(old.id,old.club_id,old.source,old.created_at,old.club_post) then raise exception 'O clube e a origem da notícia não podem ser alterados.'; end if;
 if length(new.title)>160 or length(new.summary)>400 or length(new.body)>20000 then raise exception 'Use até 160 caracteres no título, 400 no resumo e 20.000 no conteúdo.'; end if;
 if tg_op='INSERT' then new.created_at=now()::text; end if;
 new.updated_at=now()::text;
 new.author='Comunicação · '||(select name from public.clubs where id=new.club_id);
 new.featured='Não';new.player_id=null;new.match_id=null;
 return new;
end $$;
revoke all on function private.guard_club_news() from public,anon,authenticated;
create trigger guard_club_news before insert or update on public.news for each row execute function private.guard_club_news();

-- New covers only; existing files cannot be overwritten or removed by club owners.
create policy club_news_cover_insert on storage.objects for insert to authenticated
 with check(bucket_id='liga-images' and split_part(name,'/',1)='clubs' and public.can_publish_club(split_part(name,'/',2)));


-- Separação das editorias e permissões de clube
-- Tighten existing policies in place; preserve all news and existing ownership policies.
alter policy read_news on public.news using(
 status='Publicado' or (select public.liga_role())='admin'
 or (not club_post and (select public.liga_role())='editor')
);
alter policy write_news on public.news using(
 source='local' and ((select public.liga_role())='admin'
 or (not club_post and (select public.liga_role())='editor'))
) with check(
 source='local' and ((select public.liga_role())='admin'
 or (not club_post and (select public.liga_role())='editor'))
);
create or replace function private.guard_club_news() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if current_user in ('postgres','supabase_admin','service_role') or coalesce(private.liga_role()='admin',false) then return new; end if;
 if coalesce(private.liga_role()='editor',false) and not new.club_post and (tg_op='INSERT' or not old.club_post) then return new; end if;
 if auth.uid() is null or not new.club_post or new.club_id is null or new.source<>'local' or not public.can_publish_club(new.club_id) then raise exception 'Você pode publicar somente na página do seu clube.'; end if;
 if tg_op='UPDATE' and row(new.id,new.club_id,new.source,new.created_at,new.club_post) is distinct from row(old.id,old.club_id,old.source,old.created_at,old.club_post) then raise exception 'O clube e a origem da notícia não podem ser alterados.'; end if;
 if length(new.title)>160 or length(new.summary)>400 or length(new.body)>20000 then raise exception 'Use até 160 caracteres no título, 400 no resumo e 20.000 no conteúdo.'; end if;
 if tg_op='INSERT' then new.created_at=now()::text; end if;
 new.updated_at=now()::text;
 new.author='Comunicação · '||(select name from public.clubs where id=new.club_id);
 new.featured='Não';new.player_id=null;new.match_id=null;
 return new;
end $$;
alter policy images_insert on storage.objects with check(
 bucket_id='liga-images' and ((select public.liga_role())='admin'
 or ((select public.liga_role())='editor' and split_part(name,'/',1)<>'clubs'))
);
