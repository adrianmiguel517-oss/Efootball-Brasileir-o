-- Execute no SQL Editor depois de criar as DUAS contas em Authentication → Users.
-- Não contém senhas. Nunca executado pelo navegador do site.
do $$ begin
 if (select count(*) from auth.users where lower(email) in ('adrianmiguel517@gmail.com','paiivavitor07@gmail.com') and email_confirmed_at is not null)<>2 then
 raise exception 'Crie e confirme as duas contas no Supabase Authentication antes de executar.';
 end if;
end $$;
insert into public.members(id,email,role)
select id,lower(email),'admin' from auth.users
where lower(email) in ('adrianmiguel517@gmail.com','paiivavitor07@gmail.com') and email_confirmed_at is not null
on conflict(id) do update set role='admin',email=excluded.email;
