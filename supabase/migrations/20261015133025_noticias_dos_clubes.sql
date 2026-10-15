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
