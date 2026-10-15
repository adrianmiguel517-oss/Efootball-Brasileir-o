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
