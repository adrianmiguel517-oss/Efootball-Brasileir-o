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
