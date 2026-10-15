-- Identifica o formato da fase para preservar a classificação de pontos corridos.
alter table public.phases add column format text not null default 'Pontos corridos' check(format in ('Pontos corridos','Eliminatória'));
