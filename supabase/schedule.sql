-- Opcional: execute somente depois de publicar a Edge Function.
-- Ative pg_cron e pg_net em Database → Extensions primeiro.
-- Em Vault, crie liga_project_url = https://SEU-PROJETO.supabase.co
-- e liga_cron_secret = o MESMO valor forte do secret CRON_SECRET da Edge Function.
select cron.schedule('brasileirao-copafacil','*/5 * * * *', $$
 select net.http_post(
  url := (select decrypted_secret from vault.decrypted_secrets where name='liga_project_url')||'/functions/v1/copafacil',
  headers := jsonb_build_object('Content-Type','application/json','x-cron-secret',
   (select decrypted_secret from vault.decrypted_secrets where name='liga_cron_secret')),
  body := '{"action":"sync"}'::jsonb,
  timeout_milliseconds := 120000
 );
$$);
-- O painel controla enabled/interval; cada disparo verifica esses campos.
-- Parar definitivamente: select cron.unschedule('brasileirao-copafacil');
