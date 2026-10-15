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
