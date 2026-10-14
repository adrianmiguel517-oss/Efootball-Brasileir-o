# Auditoria — continuidade em 14/10/2026

## Base encontrada antes das alterações
O projeto portátil já continha 22 rotas públicas/administrativas, componentes React compilados para HTML/CSS/JS, logo fornecida, navegação, animações de clique, filtros, tabelas, busca e editor de registros. O painel já ficava em `/admin`.

Existiam backend Node HTTP, SQLite, login local, upload em disco, CRUD dos módulos e integração Copa Fácil. Isso dependia de um processo permanente; copiar esses arquivos para hospedagem estática NÃO ativaria o banco nem o login. Não havia configuração Vercel/Supabase. A documentação antiga orientava iniciar o servidor no computador.

## Trabalho preservado
`src/app/portal.tsx`, `src/lib/model.ts`, `src/main.tsx`, identidade visual, CSS, logo, páginas e navegação foram reaproveitados. `backend/`, `server.mjs`, `migrations/` e scripts antigos permanecem para referência; não entram em `dist/`, não atendem requisições na Vercel e não são o backend de produção novo. Não há banco SQLite de produção encontrado para importar.

## Implementado nesta continuação
- Adaptador Supabase para os formulários e páginas existentes, com paginação de consultas.
- Auth por senha do Supabase; papéis concedidos no banco, sem código de instalação no terminal.
- PostgreSQL relacional, RLS, auditoria, validações, transferência atômica e vínculos únicos.
- Storage público para imagens; escrita exige administrador/editor; limite de tamanho e formatos.
- Clubes oficiais com responsáveis, sem elencos, resultados, temporadas ou campeões inventados.
- Cadastro de fases/rodadas, vínculo de partidas à rodada, abas horizontais e responsáveis nos cards.
- Atualização pública ao recarregar e consulta a cada 30 segundos enquanto a página está visível.
- Editor acessa notícias, vídeos e banners; administrador acessa demais módulos.
- Estatísticas calculadas dos eventos; classificação dos placares encerrados; aproveitamento incluído.
- Build estático, rotas Vercel e variáveis públicas documentadas.
- Copa Fácil transportado para Edge Function; credencial em esquema privado, cache e transação de publicação, trava de concorrência e agendamento opcional.

## Limites reais e pendências de publicação
Na primeira revisão, não havia configuração remota. O estado atualizado da instalação está no registro abaixo. O conector GitHub retornou lista vazia de repositórios acessíveis. Testes locais não substituem verificar login, Storage e RLS no projeto Supabase real depois da instalação.

Os escudos dos seis clubes ainda devem ser enviados em Clubes; até lá aparecem marcadores com siglas, não escudos oficiais falsos. O editor de notícias existente oferece texto com formatação simples, links e vídeo relacionado; não é editor WYSIWYG completo. Votações/antifraude não foram implementadas. Rankings externos são exibidos separadamente e não viram lances inventados. Relatórios sem IDs estáveis de jogadores ficam como dados externos, sem gerar elencos.

As prévias de compartilhamento possuem metadados gerais do portal; prévias distintas por notícia/partida para robôs sem JavaScript continuam pendentes. Sem conta Copa Fácil não foi possível validar payloads reais. Importações muito grandes são abortadas com erro, preservando o snapshot anterior; não há fila paginada de longa duração. Publicação real depende da conexão das contas e do teste de aceite descrito no README.

## Verificação desta revisão
50 verificações passaram em PostgreSQL/PGlite: permissões, restrições, transferência atômica, edição idempotente de evento, cálculos, sigilo e repetição de importações. 21 rotas renderizaram sem erro no estado inicial. Build estático concluído. O código da Edge Function passou por verificação TypeScript estrita com declaração local do ambiente Deno.

Não foi possível fazer inspeção visual automatizada em navegador: o download do Chromium falhou neste ambiente. A responsividade e animações existentes foram preservadas, com novas abas horizontais em CSS; precisam ser conferidas no link publicado. Auth, Storage, cron e Copa Fácil reais aguardam configuração e teste no serviço.

## Instalação remota em 14/10/2026
- Supabase `amtaehjmgyvcyxhjlttu`, nome Efootball Brasileirão: ativo, schema relacional instalado, seis clubes oficiais confirmados, nenhum jogo/elenco fictício.
- Funções públicas privilegiadas movidas para esquema privado com wrappers sem privilégio e checagem de papel. Grants padrão foram restringidos. A auditoria de segurança do Supabase retornou zero alertas.
- Primeiro acesso: o cadastro e a confirmação do e-mail concedem o papel admin exclusivamente aos dois e-mails autorizados. Não existe senha inicial no código.
- 54 verificações PostgreSQL/PGlite passaram, incluindo reprodução de permissões padrão do Supabase e confirmação de e-mail antes do papel admin.
- REST público real: seis clubes acessíveis (HTTP 200), RPC de segredo bloqueada (HTTP 401), Edge Function Copa Fácil sem login bloqueada (HTTP 403).
- Edge Function Copa Fácil publicada, versão 2. Credenciais da competição e cron não configurados.
- Vercel `prj_1SyxwptI6uyULoMiwOdfJRHqvwa0`: projeto criado e variáveis públicas configuradas. O upload dos arquivos foi recusado (HTTP 403, escopo efootball5); não houve deploy.
- GitHub: continua sem repositório acessível. O código atual não foi enviado para GitHub.
- Login, recuperação, uploads autenticados e edição pelo painel precisam de teste de aceite após a publicação e configuração dos Redirect URLs.
