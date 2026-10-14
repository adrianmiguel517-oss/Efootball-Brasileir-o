-- Elencos podem ser cadastrados antes de conhecer posição ou titularidade.
alter table public.players alter column position drop not null;
alter table public.players drop constraint players_position_check1;
alter table public.players add constraint players_position_check1
check (position in ('GOL','ZAG','LD','LE','VOL','MC','MEI','PD','PE','SA','CA','Ponta','Lateral','Ala','Atacante'));
alter table public.memberships alter column role drop not null;
