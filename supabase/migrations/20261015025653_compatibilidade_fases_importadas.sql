-- A importação Copa Fácil usa registros JSON parciais; ausência de formato mantém pontos corridos.
alter table public.phases alter column format drop not null;
