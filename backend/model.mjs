const f = (key, label, type = 'text', required = false, ref, options) => ({ key, label, type, required, ref, options });
export const specs = {
    seasons: { label: 'Temporadas', singular: 'Temporada', fields: [f('name', 'Nome', 'text', true), f('year', 'Ano', 'number', true), f('status', 'Status', 'select', true, undefined, ['Planejada', 'Em andamento', 'Encerrada']), f('rules', 'Regulamento', 'textarea'), f('tiebreakers', 'Desempate', 'select', true, undefined, ['points,wins,gd,gf', 'points,gd,gf,wins']), f('qualify', 'Vagas de classificação', 'number'), f('relegate', 'Vagas de rebaixamento', 'number')] },
    clubs: { label: 'Clubes', singular: 'Clube', fields: [f('name', 'Nome', 'text', true), f('short', 'Sigla', 'text', true), f('color', 'Cor', 'color'), f('image', 'Escudo', 'image'), f('manager', 'Técnico / usuário'), f('formation', 'Formação tática'), f('bio', 'Sobre o clube', 'textarea')] },
    players: { label: 'Jogadores', singular: 'Jogador', fields: [f('name', 'Nome', 'text', true), f('position', 'Posição', 'select', true, undefined, ['GOL', 'ZAG', 'LD', 'LE', 'VOL', 'MC', 'MEI', 'PD', 'PE', 'SA', 'CA']), f('overall', 'Overall', 'number'), f('image', 'Foto / carta', 'image'), f('bio', 'Biografia', 'textarea')] },
    memberships: { label: 'Elencos', singular: 'Vínculo', fields: [f('season_id', 'Temporada', 'ref', true, 'seasons'), f('club_id', 'Clube', 'ref', true, 'clubs'), f('player_id', 'Jogador', 'ref', true, 'players'), f('role', 'Função', 'select', true, undefined, ['Titular', 'Reserva']), f('number', 'Camisa', 'number'), f('started', 'Entrada', 'date'), f('ended', 'Saída', 'date')] },
    matches: { label: 'Partidas', singular: 'Partida', fields: [f('season_id', 'Temporada', 'ref', true, 'seasons'), f('home_id', 'Mandante', 'ref', true, 'clubs'), f('away_id', 'Visitante', 'ref', true, 'clubs'), f('round', 'Rodada', 'number', true), f('phase', 'Fase', 'text', true), f('kickoff', 'Data e hora', 'datetime-local'), f('status', 'Status', 'select', true, undefined, ['Agendado', 'Ao vivo', 'Encerrado', 'Adiado']), f('home_score', 'Gols mandante', 'number'), f('away_score', 'Gols visitante', 'number'), f('home_possession', 'Posse mandante (%)', 'number'), f('away_possession', 'Posse visitante (%)', 'number'), f('home_shots', 'Finalizações mandante', 'number'), f('away_shots', 'Finalizações visitante', 'number'), f('home_on_target', 'Finalizações no alvo mandante', 'number'), f('away_on_target', 'Finalizações no alvo visitante', 'number'), f('home_corners', 'Escanteios mandante', 'number'), f('away_corners', 'Escanteios visitante', 'number'), f('notes', 'Escalações e observações', 'textarea')] },
    events: { label: 'Lances', singular: 'Lance', fields: [f('match_id', 'Partida', 'ref', true, 'matches'), f('club_id', 'Clube', 'ref', true, 'clubs'), f('player_id', 'Jogador', 'ref', false, 'players'), f('assist_id', 'Assistência', 'ref', false, 'players'), f('type', 'Evento', 'select', true, undefined, ['Gol', 'Gol contra', 'Cartão amarelo', 'Cartão vermelho', 'Substituição', 'Defesa', 'Destaque']), f('minute', 'Minuto', 'number', true), f('notes', 'Descrição', 'textarea')] },
    appearances: { label: 'Participações', singular: 'Participação', fields: [f('match_id', 'Partida', 'ref', true, 'matches'), f('club_id', 'Clube', 'ref', true, 'clubs'), f('player_id', 'Jogador', 'ref', true, 'players'), f('rating', 'Nota (0 a 10)', 'number'), f('starter', 'Titular', 'select', true, undefined, ['Sim', 'Não'])] },
    news: { label: 'Notícias', singular: 'Notícia', fields: [f('title', 'Título', 'text', true), f('summary', 'Resumo', 'textarea', true), f('body', 'Conteúdo (texto, links e vídeo relacionado)', 'textarea', true), f('image', 'Capa', 'image'), f('category', 'Categoria', 'select', true, undefined, ['Transferências', 'Resultados', 'Bastidores', 'Entrevistas', 'Mercado da Bola', 'Comunicados']), f('author', 'Autor', 'text', true), f('status', 'Publicação', 'select', true, undefined, ['Rascunho', 'Publicado']), f('featured', 'Destaque', 'select', false, undefined, ['Não', 'Sim']), f('club_id', 'Clube relacionado', 'ref', false, 'clubs'), f('player_id', 'Jogador relacionado', 'ref', false, 'players'), f('match_id', 'Partida relacionada', 'ref', false, 'matches'), f('video', 'YouTube', 'url')] },
    videos: { label: 'Vídeos', singular: 'Vídeo', fields: [f('title', 'Título', 'text', true), f('url', 'Link do YouTube', 'url', true), f('image', 'Capa', 'image'), f('category', 'Categoria', 'select', true, undefined, ['Golaços', 'Defesas', 'Melhores lances', 'Compilações']), f('season_id', 'Temporada', 'ref', false, 'seasons'), f('match_id', 'Partida', 'ref', false, 'matches'), f('club_id', 'Clube', 'ref', false, 'clubs'), f('player_id', 'Jogador', 'ref', false, 'players'), f('status', 'Publicação', 'select', true, undefined, ['Rascunho', 'Publicado'])] },
    transfers: { label: 'Transferências', singular: 'Transferência', fields: [f('season_id', 'Temporada', 'ref', true, 'seasons'), f('player_id', 'Jogador', 'ref', true, 'players'), f('from_id', 'Origem', 'ref', false, 'clubs'), f('to_id', 'Destino', 'ref', true, 'clubs'), f('value', 'Valor (R$)', 'number'), f('date', 'Data', 'date', true), f('status', 'Status', 'select', true, undefined, ['Em negociação', 'Confirmada']), f('news_id', 'Notícia relacionada', 'ref', false, 'news')] },
    titles: { label: 'Museu e títulos', singular: 'Título', fields: [f('season_id', 'Temporada', 'ref', true, 'seasons'), f('club_id', 'Campeão', 'ref', true, 'clubs'), f('runner_id', 'Vice-campeão', 'ref', false, 'clubs'), f('name', 'Competição', 'text', true), f('image', 'Foto histórica', 'image'), f('story', 'História da edição', 'textarea')] },
    awards: { label: 'Premiações', singular: 'Premiação', fields: [f('season_id', 'Temporada', 'ref', true, 'seasons'), f('name', 'Prêmio', 'select', true, undefined, ['Craque da rodada', 'Seleção da rodada', 'Melhor jogador', 'Artilheiro', 'Melhor goleiro', 'Melhor técnico', 'Bola de Ouro', 'Hall da Fama', 'Recorde']), f('player_id', 'Jogador', 'ref', false, 'players'), f('club_id', 'Clube', 'ref', false, 'clubs'), f('round', 'Rodada', 'number'), f('description', 'Descrição', 'textarea'), f('image', 'Imagem', 'image')] },
    sponsors: { label: 'Patrocinadores', singular: 'Patrocinador', fields: [f('name', 'Nome', 'text', true), f('image', 'Logo', 'image', true), f('url', 'Site', 'url')] },
    banners: { label: 'Destaques da home', singular: 'Destaque', fields: [f('title', 'Título', 'text', true), f('description', 'Descrição', 'textarea'), f('image', 'Imagem', 'image'), f('url', 'Destino (URL ou caminho)', 'text'), f('status', 'Status', 'select', true, undefined, ['Publicado', 'Rascunho'])] }
};
export function youtubeId(url) { try {
    const u = new URL(url);
    const id = u.hostname === 'youtu.be' ? u.pathname.slice(1) : ['www.youtube.com', 'youtube.com', 'm.youtube.com'].includes(u.hostname) ? u.searchParams.get('v') || u.pathname.split('/').pop() : null;
    return id && /^[\w-]{11}$/.test(id) ? id : null;
}
catch {
    return null;
} }
export function tableRows(clubs, matches, season, maxRound) { const rows = clubs.map(c => ({ ...c, points: 0, played: 0, wins: 0, draws: 0, losses: 0, gf: 0, ga: 0, gd: 0, form: [] })); const map = new Map(rows.map(c => [c.id, c])); for (const m of [...matches].sort((a, b) => a.round - b.round)) {
    if (m.status !== 'Encerrado' || m.home_score == null || m.away_score == null || maxRound && m.round > maxRound)
        continue;
    const h = map.get(m.home_id), a = map.get(m.away_id);
    if (!h || !a)
        continue;
    for (const [t, g, against] of [[h, m.home_score, m.away_score], [a, m.away_score, m.home_score]]) {
        t.played++;
        t.gf += g;
        t.ga += against;
        t.gd = t.gf - t.ga;
        const won = g > against, draw = g === against;
        t.points += won ? 3 : draw ? 1 : 0;
        t.wins += +won;
        t.draws += +draw;
        t.losses += +(!won && !draw);
        t.form.push(won ? 'V' : draw ? 'E' : 'D');
    }
} const keys = (season?.tiebreakers || 'points,wins,gd,gf').split(','); return rows.sort((a, b) => { for (const k of keys) {
    const d = b[k] - a[k];
    if (d)
        return d;
} return a.name.localeCompare(b.name, 'pt-BR'); }); }
export function playerStats(players, events, appearances) { return players.map(p => { const pe = events.filter(e => e.player_id === p.id); const apps = appearances.filter(a => a.player_id === p.id); const goals = pe.filter(e => e.type === 'Gol').length, assists = events.filter(e => e.assist_id === p.id && e.type === 'Gol').length; return { ...p, goals, assists, contributions: goals + assists, played: new Set(apps.map(a => a.match_id)).size, rating: apps.filter(a => a.rating != null).length ? apps.reduce((s, a) => s + (a.rating || 0), 0) / apps.filter(a => a.rating != null).length : null }; }).sort((a, b) => b.goals - a.goals || b.assists - a.assists); }
