# BRASILEIRÃO EFOOTBALL

Este é o projeto existente, atualizado para **Vercel + Supabase**. Portal e painel ficam no mesmo endereço: `/` e `/admin`. Nenhum servidor Node permanente é necessário. A Vercel usa Node somente para compilar o JavaScript durante o deploy.

## Estado desta instalação em 14/10/2026

O banco **Efootball Brasileirão** já está configurado no Supabase (projeto `amtaehjmgyvcyxhjlttu`). As três migrações, as políticas RLS, o bucket de imagens e os seis clubes foram instalados e verificados. A Edge Function `copafacil` está publicada; ainda precisa da chave Copa Fácil e do agendamento para sincronizar.

O projeto Vercel `brasileirao-efootball` foi criado e recebeu as duas variáveis públicas do Supabase. A publicação está pendente: a Vercel recusou o upload dos arquivos por falta de acesso ao escopo `efootball5`. O acesso de escrita foi liberado para `adrianmiguel517-oss/Efootball-Brasileir-o`. Nenhum site foi publicado na Vercel nesta etapa.

**Não execute `INSTALAR.sql` neste banco novamente.** Os passos de criação abaixo são referência para um banco novo. Para continuar a instalação atual, importe o repositório `adrianmiguel517-oss/Efootball-Brasileir-o` na Vercel; depois configure os endereços de login do Supabase e faça o primeiro acesso no portal.

## O que você precisa fazer pelo celular

### 1. Repositório do projeto

O código do projeto existente está na branch `main` de https://github.com/adrianmiguel517-oss/Efootball-Brasileir-o. Não precisa baixar arquivos, extrair pastas ou utilizar VS Code.

Quando esse repositório estiver conectado à Vercel, alterações no código gerarão novos deploys. Resultados, elencos e notícias salvos no painel usam o Supabase e não precisam de deploy.

### 2. Criar o Supabase

Abra https://supabase.com/dashboard e crie um projeto. Guarde a senha do banco no seu gerenciador de senhas; não envie senhas nesta conversa. Se o menu ficar escondido no celular, use “Versão para computador” no navegador.

No repositório GitHub, abra `supabase/INSTALAR.sql`, toque em **Raw** e copie o conteúdo. No Supabase, abra **SQL Editor → New query**, cole e toque **Run**. Execute uma vez em um projeto novo. Esse arquivo cria tabelas, regras, bucket e os seis clubes. NÃO execute os arquivos da pasta antiga `migrations/`: eles são SQLite.

Se houver um banco Supabase com dados anteriores, pare antes de executar: este instalador é para um banco novo e precisa ser adaptado à estrutura existente, sem apagar dados.

### 3. Primeiro acesso dos administradores

Após a configuração dos endereços de login do Supabase (passo 4), abra `/admin` no portal e toque em **Primeiro acesso dos administradores**. Use `adrianmiguel517@gmail.com` ou `paiivavitor07@gmail.com`, crie uma senha pessoal com pelo menos 12 caracteres e confirme o cadastro no e-mail recebido.

O banco concede acesso administrativo somente depois da confirmação do e-mail. Nenhuma senha é predefinida ou incluída no projeto. Se já tiver conta, use Entrar. A opção Esqueci minha senha envia o link para redefinição. Cada titular deve fazer seu próprio cadastro.

Alternativa pelo painel Supabase: Authentication → Users → Add user → Create new user, com e-mail confirmado. O mesmo gatilho concede a permissão aos dois e-mails autorizados, sem colar SQL. Não use cadastro público para conceder outros papéis. Para editores, crie/confirme a conta em Authentication e autorize seu e-mail em `/admin` → Permissões.

### 4. Publicar na Vercel

Abra https://vercel.com/new, entre com GitHub e importe o repositório. Use:

| Configuração | Valor |
|---|---|
| Framework Preset | Other |
| Root Directory | raiz do repositório |
| Build Command | `npm run build` |
| Output Directory | `dist` |
| Install Command | padrão da Vercel (`npm install`) |

Em **Environment Variables**, cadastre os dois valores públicos do seu Supabase, encontrados em **Connect** ou **Project Settings → API Keys**:

| Nome | Valor |
|---|---|
| `SUPABASE_URL` | URL `https://...supabase.co` do projeto |
| `SUPABASE_PUBLISHABLE_KEY` | chave pública `sb_publishable_...` ou chave legada `anon` |
| `SITE_URL` | URL final do portal; opcional no primeiro deploy |

Nunca coloque `service_role`, `sb_secret_...`, senha do banco ou chave Copa Fácil nessas variáveis. Clique **Deploy**. A Vercel fornecerá seu link.

No Supabase → **Authentication → URL Configuration**, coloque o link da Vercel em Site URL e o endereço `https://SEU-SITE.vercel.app/admin` e `https://SEU-SITE.vercel.app/recuperar-senha` nas Redirect URLs. Se alterar variáveis públicas da Vercel, faça um Redeploy uma vez. Atualizações de conteúdo não precisam disso.

### 5. Organizar o campeonato

Abra `https://SEU-SITE.vercel.app/admin` e entre com sua conta. Siga esta ordem:

1. Crie a temporada, regulamento e critérios.
2. Crie as fases e as rodadas.
3. Confira os seis clubes e envie os escudos em **Clubes → Editar → Enviar imagem**.
4. Cadastre jogadores e depois os vínculos em **Elencos**.
5. Cadastre partidas escolhendo a rodada e os clubes.
6. Salve placares/status em **Partidas**, gols e assistências em **Lances**, escalações/notas em **Participações**.

O placar informado alimenta a classificação quando a partida está Encerrada. Lances alimentam artilharia e assistências; não somam novamente ao placar. É possível cadastrar os lances depois do resultado. A organização deve conferir se os lances representam todos os gols do placar. Editar o mesmo lance mantém seu ID e não duplica sua contagem.

Todas as páginas consultam o mesmo PostgreSQL. Visitantes veem alterações ao recarregar ou em até cerca de 30 segundos com a página visível e a rede disponível. A aba retoma a consulta ao voltar ao primeiro plano. Não há dependência do celular do administrador ficar aberto. LocalStorage é usado pelo SDK somente para a sessão de autenticação; não armazena o campeonato.

### 6. Teste de aceite antes de divulgar

Abra uma janela anônima no celular e confirme que Home, Clubes, Jogos, Classificação e notícias publicadas carregam. Entre em `/admin` em outra aba. Cadastre uma notícia em rascunho: ela não pode aparecer na janela anônima. Publique e aguarde a atualização. Teste um upload de escudo, o login dos dois administradores e a restrição de um editor.

Use uma temporada de homologação separada se precisar testar resultados; não apresente jogos de teste como parte da competição. Confira a atualização dos pontos, gols e assistências antes de divulgar o link. Confira também os logs. Os testes locais automatizados não substituem essa verificação no seu projeto real.

### 7. Copa Fácil — opcional, depois do portal manual

O site funciona sem essa integração. Para ativar pelo navegador:

1. Supabase → **Edge Functions → Deploy a new function → Via Editor**.
2. Nome: `copafacil`. Cole o conteúdo completo de `supabase/functions/copafacil/index.ts` e publique.
3. Desative a verificação legada de JWT na configuração da função (`verify_jwt=false`). A função verifica o JWT com `auth.getUser` e exige papel admin; o agendamento usa segredo próprio. Não remova essas verificações do código.
4. No portal → Copa Fácil, informe ID, chave, temporada, módulos e salve. A chave é enviada por HTTPS à função e guardada em esquema privado, sem leitura pública.
5. Teste a conexão. Sincronize e consulte os status recebidos. Configure o mapa de status conforme a resposta real, usando os valores permitidos. A documentação não enumera os status de partidas; não adivinhamos esses códigos.
6. Para automatizar, crie um segredo aleatório forte `CRON_SECRET` em Edge Functions → Secrets. Em Supabase Vault, crie `liga_cron_secret` com o mesmo valor e `liga_project_url` com a URL do projeto. Ative `pg_cron` e `pg_net` em Database → Extensions. Execute `supabase/schedule.sql` no SQL Editor. Depois ative a sincronização no portal.

O cron dispara a cada cinco minutos; a função respeita o intervalo configurado, arredondado pelo próximo disparo. Não há websocket nem atualização instantânea garantida. Desativar no painel interrompe as importações periódicas. O cron continuará fazendo consultas leves até ser removido.

Cache é publicado atomicamente; erro mantém a última importação válida. Há trava de concorrência, limite de 100 consultas e limite aproximado de 90 segundos por execução. Grandes campeonatos podem exigir sincronização por lotes adicional. Não foi testado com credenciais reais de Copa Fácil. Relatórios sem identificadores estáveis não criam jogadores/elencos automaticamente.

### 8. Backup e manutenção

Painel → Histórico e backup → Exportar JSON inclui todos os registros e logs. Imagens devem ser preservadas também no Supabase Storage: o JSON guarda referências. Consulte as opções de backup do plano Supabase escolhido. Este export não é um restaurador automático.

Só mudanças de código geram novos deploys pela integração GitHub/Vercel. Migrations futuras precisam ser aplicadas ao Supabase pelo SQL Editor antes de usar recursos novos. Não reaplique `INSTALAR.sql` nem apague tabelas para atualizar o portal.

## Arquitetura e verificação

- `src/app/portal.tsx`: interface existente, páginas e painel integrado.
- `src/lib/api.ts`: dados, Auth, Storage e chamada da Edge Function.
- `src/lib/model.ts`: formulários, classificação e estatísticas.
- `supabase/migrations/`: schema PostgreSQL/RLS e funções transacionais.
- `supabase/functions/copafacil/`: integração isolada.
- `dist/`: única pasta publicada, gerada no build.
- `backend/`, `server.mjs`, `migrations/`: implementação SQLite anterior preservada; não utilizada na Vercel.

Para quem desenvolve: `npm ci`, `npm test`, `npm run build`. O teste usa PostgreSQL em WASM/PGlite com contratos locais de Auth/Storage. Não faz login em contas reais. A auditoria e as limitações estão em `docs/AUDITORIA.md`.

Referências oficiais consultadas: https://supabase.com/docs/guides/database/postgres/row-level-security · https://supabase.com/docs/guides/functions/quickstart-dashboard · https://supabase.com/docs/guides/functions/schedule-functions · https://vercel.com/docs/project-configuration/vercel-json · https://www1.copafacil.com/doc_api/pt.html

## Totais importados de rankings

Em `/admin` → Totais de gols e assistências, registre os totais da temporada por jogador. Esses registros substituem o cálculo por lances de gols e assistências, sem somar os dois. Atualize-os após novos resultados ou remova-os quando o histórico de eventos estiver completo e conferido. O filtro por rodada usa somente eventos registrados, pois o ranking importado não informa em qual partida ocorreu cada gol.

## Semifinais

A página `/semifinais` usa as partidas da fase Semifinais da temporada selecionada. Tem links para clubes e partidas, destaque na Home e espaço para a final, sem escolher vencedores automaticamente. Cadastre a final no painel quando os confrontos estiverem definidos. Nas fases, escolha o formato Eliminatória para que esses resultados não entrem na classificação por pontos. Formato de ida/volta, datas e resultados só devem ser cadastrados após confirmação da organização.

## Liga Bet — exclusivamente moeda virtual

A página `/apostas` reúne jogos, odds, bilhetes, carteira, extrato e ranking. Não existe depósito, PIX, dinheiro real ou transferência automática pelo WhatsApp. Cada clube tem 15 Mi de crédito único por temporada; não existe recarga na mesma temporada. Com saldo disponível de pelo menos 30 Mi, pode solicitar parte ou tudo. O valor sai do disponível ao solicitar. Aprovação registra o crédito virtual que o administrador fez na conta de contratações do WhatsApp; recusa devolve o valor, uma única vez.

### Começar pelo celular

1. O participante abre Liga Bet → Primeiro acesso do participante, cria a conta e confirma seu e-mail.
2. O administrador abre Liga Bet → Gestão. Inicializar carteiras cria apenas carteiras ausentes, sem repor saldo.
3. Em Vincular responsável, seleciona o clube e o e-mail confirmado. Um e-mail representa um clube por temporada. Não compartilhe senhas.
4. Em Mercados, define o encerramento das apostas e abre o jogo. Jogos encerrados não aceitam apostas; sem horário de início cadastrado, é obrigatório fechar o mercado antes de começar a jogar.
5. Registra o placar no painel, confere e usa Liquidar resultado. Bilhetes recebem o retorno total (valor apostado incluído) ou ficam perdidos. Anular/devolver restitui os valores pendentes. Para W.O., confira e anule o mercado.
6. Confirme uma retirada somente depois de registrar seu crédito virtual no WhatsApp, com referência na observação. Não há ferramenta de envio de mensagens.

As odds 1X2 são calculadas no servidor a partir do aproveitamento e gols da temporada, com suavização de três jogos e probabilidades Poisson (0–12 gols, normalizadas), margem virtual de 6%, limites de 1,05 a 20. É um modelo de jogo da liga, não previsão garantida. Reabrir/recalcular altera apenas novas apostas; bilhetes conservam suas odds. O mercado considera o placar confirmado da partida, não classificado, prorrogação ou disputa por pênaltis separadamente.

Movimentações usam transações, locks de partida/mercado/carteira e identificadores de confirmação idempotentes. As tabelas não aceitam escrita direta de participantes, editores ou administradores do portal; somente RPCs com autorização movimentam os valores. Extratos pessoais ficam restritos ao dono e à organização. Resultados liquidados são protegidos contra edição: corrigir um placar após pagamento exige reconciliação da organização para preservar valores já retirados, e não deve ser feito diretamente no banco sem essa revisão.

Verificação específica da Liga Bet: `node scripts/test-betting.mjs`. O teste PostgreSQL (`npm test`) também verifica recusa de saldo insuficiente, idempotência, liquidação, devolução, retirada total, permissões e proteção de resultados pagos.

### Notícias de cada clube

No menu Voz dos clubes (`/noticias/clubes`), cada time tem sua própria página em `/clubes/ID/noticias`. O perfil do clube e a carteira da Liga Bet também levam até essa página. Visitantes leem as matérias publicadas; o responsável vinculado ao clube, com temporada em andamento, encontra Gerenciar notícias do clube. O vínculo é o mesmo e-mail confirmado atribuído pela administração na Liga Bet. Não há autocadastro como dono de outro time.

O responsável publica, edita, exclui e salva rascunhos das matérias do próprio clube. Capas aceitam JPG/PNG/WebP de até 5 MB, ou URL HTTPS. A autoria é identificada pelo clube e o destaque na página inicial continua sob controle editorial. As matérias publicadas aparecem na central Voz dos clubes e na seção da página inicial; notícias da organização ficam separadas em `/noticias`. Rascunhos ficam privados. Apenas administradores gerenciam todos os clubes; editores cuidam das notícias da liga e, caso vinculados a um clube, somente da própria redação. As permissões são verificadas no banco, incluindo capas e tentativas de mudar o clube da matéria. Mudanças de responsável ou fim da temporada encerram o acesso do responsável anterior, mantendo as matérias publicadas.

### Autenticação em produção e limite de e-mails

Origem de produção verificada: `https://efootball-brasileir-o.vercel.app`. Participantes entram em `/entrar`; o link Entrar na liga está no topo. Essa conta é a mesma da Liga Bet e das notícias dos clubes. Administradores usam `/admin`.

No Supabase → Authentication → URL Configuration, usar Site URL `https://efootball-brasileir-o.vercel.app` e autorizar os redirects exatos:
- `https://efootball-brasileir-o.vercel.app/apostas`
- `https://efootball-brasileir-o.vercel.app/admin`
- `https://efootball-brasileir-o.vercel.app/recuperar-senha`

Não usar URLs de exemplo ou localhost em produção. O código usa a origem canônica para cadastro, reenvio e recuperação, e traduz erros de links expirados. Mudança de sessão atualiza o portal sem esperar o próximo intervalo de atualização.

O provedor padrão de e-mail do Supabase possui limite compartilhado de 2 envios/hora e restrições de destinatários; não atende ao cadastro de todos os participantes. Configurar um SMTP de produção ou Send Email Hook no serviço, mantendo confirmação de e-mail. Não aumentar tentativas nem confirmar usuários manualmente para contornar a verificação. Configure o remetente e as credenciais pelo painel seguro do provedor; não incluir senhas ou tokens no repositório. O site impõe um intervalo local entre solicitações e não envia e-mail para entrar com senha. Mensagens em português distinguem credenciais incorretas, e-mail não confirmado e limite de envio. Links antigos enviados para um endereço errado não são corrigidos retroativamente; solicitar um novo após a configuração.


### Acesso com Google (código preparado; requer ativação do provedor)

Os formulários de participantes e administradores consultam `/auth/v1/settings` e exibem Entrar com Google somente quando `external.google` está ativo. Um provedor desativado não aparece como alternativa funcional. O login usa `signInWithOAuth`, seleção de conta e os redirects já autorizados `/apostas` ou `/admin`. Nenhuma tabela, confirmação de e-mail ou regra de vínculo é alterada.

A ativação exige um cliente OAuth Web no Google Auth Platform, com origem `https://efootball-brasileir-o.vercel.app` e callback `https://amtaehjmgyvcyxhjlttu.supabase.co/auth/v1/callback`. O Client ID e Client Secret são configurados diretamente no provedor Google do Supabase; nunca no código público nem no chat. Publique a configuração OAuth para os participantes, em vez de deixá-la limitada aos usuários de teste. Documentação: https://supabase.com/docs/guides/auth/social-login/auth-google

Após ativar: abrir `/entrar`, escolher Google, confirmar a conta e conferir o retorno autenticado, o vínculo do clube e a persistência após recarregar. Contas já existentes devem usar o mesmo e-mail do responsável. O login completo com Google ainda precisa desse teste real após a configuração.


### Verificação do login simplificado

A entrada padrão é e-mail e senha, com abas Entrar/Criar conta e atalhos de recuperação. O cliente mantém a sessão no navegador e renova os tokens. Cadastro pendente mantém a senha apenas na memória do formulário e oferece Já confirmei — entrar, sem novo cadastro ou envio automático de mensagem. Senhas nunca são persistidas pelo formulário. A confirmação inicial do Supabase continua habilitada; ela não é solicitada em cada login.

`node scripts/test-login-sdk.mjs` usa o SDK real com transporte simulado para conferir senha incorreta, conta pendente, cadastro, login, normalização do e-mail, restauração de sessão sem chamadas de envio, renovação de token, reenvio manual, recuperação e saída. Esses testes não comprovam entrega SMTP nem substituem a confirmação de recebimento pelo destinatário.


### Meu clube e responsáveis

`/meu-clube` é o ponto de entrada para login, perfil, notícias do próprio clube e atalho para a Liga Bet. `/entrar` continua como rota compatível para a mesma central. No painel admin, Responsáveis dos clubes (`/admin?secao=responsaveis`) é uma seção própria; o vínculo não depende de navegar pela interface de apostas. A mesma identidade de responsável é usada nas notícias e na carteira. Não há concessão automática de clube ou de administrador pelo e-mail digitado no cadastro. As permissões existentes por UUID são preservadas.

Cadastro sem confirmação: o código já aceita a sessão imediata retornada por `signUp`. No projeto hospedado, é necessário desativar **Confirm email** em Authentication → Sign In / Providers → Email. Isso é configuração do Supabase Auth, não migração SQL. A integração MCP usada aqui não oferece alteração dessas configurações. A migração centralizar_gestao_dos_clubes remove a promoção automática de administradores por endereço antes desse ajuste. Contas antigas pendentes continuam dependendo de confirmação manual pela organização na área Users. Nunca conceder administrador automaticamente a um cadastro novo por endereço de e-mail.
