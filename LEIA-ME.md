ATUALIZAÇÃO: para Vercel + Supabase e publicação pelo celular, siga README.md. As instruções abaixo pertencem à versão antiga com servidor local e NÃO são necessárias para a Vercel.

# BRASILEIRÃO EFOOTBALL — Site HTML com painel integrado

Este pacote é seu projeto independente. Não usa hospedagem, conta ou login do ChatGPT.

O portal e o painel utilizam **o mesmo `index.html`, o mesmo endereço e o mesmo banco**. O botão **Área da liga** abre a administração dentro do site. A rota `/admin` é apenas uma seção protegida do portal, não outro site.

## Como abrir

### Só para ver o visual

Extraia o ZIP e abra `index.html`. Você consegue navegar pelo visual. Ao abrir o arquivo diretamente, não há servidor para executar login ou gravar no banco; o próprio site informa isso.

### Para usar o site completo

1. Instale o **Node.js 24 ou superior**: https://nodejs.org
2. Extraia o ZIP para uma pasta no computador.
3. No Windows, abra `iniciar-windows.bat`. No Mac/Linux, execute `sh iniciar-mac-linux.sh` na pasta. Alternativamente, abra um terminal na pasta e execute:

   ```sh
   npm start
   ```

4. Abra **http://localhost:3000** no navegador.
5. Clique em **Área da liga**. No primeiro uso, informe o **código de instalação que aparece no terminal** e defina as duas senhas.

Não precisa rodar `npm install` para usar a versão entregue: o JavaScript do navegador já está compilado, e o servidor utiliza os módulos nativos do Node.js.

## Administradores

As contas abaixo já estão reservadas com permissão de administrador:

- `adrianmiguel517@gmail.com`
- `paiivavitor07@gmail.com`

Você define uma senha para cada uma na configuração inicial. Nenhuma senha pronta ou senha compartilhada foi incluída no arquivo. Depois disso, cada pessoa entra com e-mail e senha. O cadastro inicial não envia mensagens nem verifica acesso às caixas de e-mail: quem controla a instalação define as senhas e deve entregá-las às pessoas corretas.

Senhas são armazenadas como hashes com salt; sessões usam cookies HttpOnly. Login no navegador não libera acesso por apenas digitar um e-mail. Os controles de permissão são verificados no servidor.

No painel, **Permissões → Alterar minha senha** permite trocar a própria senha. Para recuperar acesso tendo controle do servidor, execute:

```sh
npm run reset-password
```

O comando solicita o e-mail e a nova senha sem mostrar a senha digitada, e encerra as sessões antigas. Em Permissões também é possível criar editores, informando uma senha inicial, sem enviar e-mails automaticamente.

## Primeiros cadastros

1. **Temporadas:** nome, ano, regulamento e desempate.
2. **Clubes:** nome, escudo, cor, formação e responsável.
3. **Jogadores:** nome, posição, overall e foto/carta.
4. **Elencos:** vincule cada jogador ao clube e à temporada.
5. **Partidas:** rodada, fase, clubes, data, placar e status.
6. **Lances:** gols, assistências, cartões e outros eventos.
7. **Participações:** jogadores que atuaram, titulares/reservas e notas.

A classificação considera somente partidas encerradas. Os gols e as assistências individuais vêm dos lances; jogos e notas individuais vêm de Participações. O placar da partida é informado pelo administrador, permitindo lançar o resultado antes de detalhar os autores dos gols.

Uma transferência confirmada encerra o vínculo anterior e cria o vínculo do clube de destino na mesma transação. O histórico é preservado.

O conteúdo inicial está vazio: não foram inventados jogos, resultados, elencos ou campeões.

## O que está incluído

- Portal responsivo com sua logo, fundo claro, azul e verde.
- Home, jogos, calendário, classificação, clubes, elencos e perfis dos jogadores.
- Notícias com rascunho, prévia, formatação, imagens e vídeos.
- Lances, rankings, comparação de clubes, transferências e histórico de temporadas.
- Museu, títulos, vice-campeões, prêmios, recordes e Hall da Fama editáveis.
- Painel integrado com login, administradores, editores, upload, logs e exportação.
- Busca, links compartilháveis, metadados para compartilhamento e página 404.
- Animação de clique, resposta dos botões, transição de páginas, abertura de modais e efeitos leves nos cards. A preferência de redução de movimento do dispositivo é respeitada.
- Integração Copa Fácil no backend e sincronização periódica enquanto o processo do servidor estiver ativo, mesmo que nenhum navegador esteja aberto.

## Copa Fácil

Abra **Área da liga → Copa Fácil**. Informe sua chave, o ID do campeonato e a temporada de destino. Salve, teste a conexão e sincronize.

A documentação utilizada é: https://www1.copafacil.com/doc_api/pt.html

A chave fica no servidor e não é retornada ao navegador, incluída nos logs ou no backup JSON do painel. Dados locais e externos podem ser alternados.

Como a documentação não enumera todos os valores de status das partidas, sincronize uma vez, veja os valores recebidos em “Consultar dados recebidos” e configure o mapa para `Agendado`, `Ao vivo`, `Encerrado` e `Adiado`. Em seguida, sincronize novamente.

Ative **Sincronização automática no servidor** para rodar no intervalo escolhido. O servidor verifica o agendamento uma vez por minuto e evita repetir execuções antes do intervalo. Não há WebSocket. O portal consulta o banco a cada 60 segundos. Se o servidor parar, a sincronização também para; ao reiniciar, uma atualização vencida volta a ser considerada.

A integração foi testada com respostas simuladas. A conexão com seu campeonato ainda depende das credenciais reais. Relatórios externos com identificação/colunas desconhecidas ficam disponíveis para inspeção; o sistema não inventa elencos a partir desses relatórios. A identificação de equipes nas partidas usa o nome normalizado como fallback quando a origem não informa um ID. Revise o adaptador caso a origem mude nomes ou estrutura.

## Publicar no seu domínio

Este projeto requer uma hospedagem que execute **Node.js 24+** e tenha **disco persistente**. Uma hospedagem exclusivamente estática pode exibir o HTML, mas não executar o login, o banco e as sincronizações.

Envie o pacote e configure:

- Comando de início: `npm start`.
- `HOST=0.0.0.0` para aceitar conexões da hospedagem.
- `PORT`: a porta fornecida pela hospedagem.
- `APP_ORIGIN=https://seudominio.com.br`.
- `COOKIE_SECURE=true` quando estiver usando HTTPS.
- `DATA_DIR`: diretório de um disco/volume persistente.

Há um `.env.example`. Você pode copiá-lo para `.env` e ajustar os valores. O comando de início carrega `.env` quando ele existe. Não publique esse arquivo nem a pasta `data` como arquivos estáticos.

Use HTTPS no domínio e mantenha apenas **uma instância do servidor** para este pacote SQLite. O servidor entrega apenas o HTML, os assets e os arquivos enviados pelas rotas autorizadas; não entrega o código do backend nem o arquivo do banco.

## Onde ficam os dados e como fazer backup

Por padrão, são criados ao iniciar:

- `data/liga.sqlite`: banco de dados.
- `data/uploads/`: imagens enviadas.

Esses dados **não estão dentro do ZIP inicial**. São criados no seu computador ou na sua hospedagem. O banco não utiliza localStorage como armazenamento dos registros da liga.

O painel exporta JSON dos registros e do histórico, sem senhas e sem a chave da integração. Esse JSON contém as referências às imagens, não os arquivos de imagem.

Para um backup completo, pare o servidor e copie **a pasta de dados inteira**, incluindo os arquivos auxiliares do SQLite quando existirem e `uploads/`. Para restaurar, pare o servidor, recoloque essa pasta no mesmo caminho e reinicie. Proteja esse backup: o banco completo contém hashes de senha e credenciais da integração. Não há importador de JSON no painel.

## Arquivos para editar

- `index.html`: entrada única do portal e do painel.
- `assets/styles.css`: estilos e animações.
- `assets/logo.jpg`: sua logo.
- `assets/app.js`: JavaScript pronto para o navegador.
- `src/`: fonte legível da interface em React/TypeScript.
- `backend/`: JavaScript do servidor, autenticação, regras e integração.
- `server.mjs`: servidor HTTP e agendador.
- `migrations/`: estrutura do banco, aplicada automaticamente no início.

O resultado entregue ao navegador é HTML, CSS e JavaScript. Para alterar a lógica da interface, edite `src/` e recompile:

```sh
npm install
npm run build
```

Não é necessário recompilar para modificar apenas o CSS. Não edite migrações que já foram aplicadas em um banco com dados.

## Verificação e limites

Execute `npm test`. Os testes usam um banco temporário e não mexem nos dados da sua liga. Verificam os dois administradores, login, instalação, bloqueios de permissão, alteração de senha, dados privados, transferências, imagens, proteção de credenciais e execução do agendamento sem navegador.

A revisão visual em navegador não foi realizada neste ambiente. Votações públicas opcionais e importação automática de relatórios de jogadores com campos desconhecidos não foram implementadas. Não há serviços externos contratados ou credenciais de hospedagem/Copa Fácil incluídas.
