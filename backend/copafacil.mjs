import { db, setting, setSetting, upsert } from './server.mjs';
async function runSync(test = false) {
    const c = await setting('integration', {}), key = await setting('copafacil_key');
    if (!key || !c.tournament)
        throw new Error('Configure a chave e o ID do campeonato antes de conectar.');
    const base = 'https://copafacil.com/api2/tournament/' + encodeURIComponent(c.tournament);
    let count = 0;
    async function get(path) { if (++count > 400)
        throw new Error('Campeonato excede o limite de 400 consultas por sincronização.'); const r = await fetch(base + path, { headers: { 'x-api-key': key, lang: 'pt', gmt: '-3' }, signal: AbortSignal.timeout(15000) }); if (!r.ok)
        throw new Error('Copa Fácil retornou HTTP ' + r.status + '. Verifique credenciais e acesso ao campeonato.'); return r.json(); }
    const stages = await get('/stages');
    if (!Array.isArray(stages))
        throw new Error('Resposta inesperada para fases.');
    if (test)
        return { ok: true, message: `Conexão confirmada. ${stages.length} fase(s) disponível(is).` };
    await db().prepare("INSERT OR IGNORE INTO settings(id,value) VALUES('sync_lock','0')").run();
    const now = Date.now();
    const lease = await db().prepare("UPDATE settings SET value=? WHERE id='sync_lock' AND CAST(value AS INTEGER)<?").bind(String(now + 600000), now).run();
    if (!lease.meta.changes)
        throw new Error('Já existe uma sincronização em andamento.');
    try {
        const mods = c.modules || [], stamp = new Date().toISOString();
        const cache = [];
        const writes = [];
        const cached = (id, kind, data) => cache.push({ id, kind, data });
        cached('stages', 'stages', stages);
        const teamMap = new Map();
        const normalize = (n) => n.trim().toLocaleLowerCase('pt-BR');
        async function team(name, externalId, photo) { if (!name)
            throw new Error('Equipe sem nome recebida.'); const normalized = normalize(name); if (teamMap.has(normalized))
            return teamMap.get(normalized); const hash = Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(c.tournament + ':' + normalized)))).map(x => x.toString(16).padStart(2, '0')).join('').slice(0, 24); const id = 'cfclub:' + hash; teamMap.set(normalized, id); writes.push(upsert('clubs', id, { tournament_id: c.tournament, name, short: name.slice(0, 3).toUpperCase(), color: '#087750', image: photo && /^https:\/\//.test(photo) ? photo : null, manager: null, bio: null }, 'copafacil')); return id; }
        if (mods.includes('teams') || mods.includes('players')) {
            const teams = await get('/teams');
            cached('teams', 'teams', teams);
            cached('teamkeys', 'teamkeys', await get('/teams/keys'));
            for (const t of teams.teams || [])
                await team(t.name, t.id, t.photo);
        }
        for (const stage of stages) {
            const sid = encodeURIComponent(stage.id);
            if (mods.includes('table')) {
                const table = await get('/stages/' + sid + '/table');
                cached('table:' + stage.id, 'table', { ...table, stageTitle: stage.title });
                for (const t of table.teams || [])
                    await team(t.name, t.id, t.photo);
            }
            if (mods.includes('matches')) {
                if (!c.season_id || !await db().prepare('SELECT id FROM seasons WHERE id=?').bind(c.season_id).first())
                    throw new Error('Selecione uma temporada local para vincular as partidas.');
                const rounds = await get('/stages/' + sid + '/rounds');
                cached('rounds:' + stage.id, 'rounds', { stage: stage.title, rounds });
                let index = 0;
                for (const round of rounds) {
                    index++;
                    const games = await get('/stages/' + sid + '/rounds/' + encodeURIComponent(round.id) + '/matchs');
                    cached('matches:' + round.id, 'matches', { stage: stage.title, round: round.title, matches: games });
                    for (const m of games) {
                        const home = await team(m.teams?.team_1?.name), away = await team(m.teams?.team_2?.name);
                        const status = c.statusMap?.[m.status];
                        if (!['Agendado', 'Ao vivo', 'Encerrado', 'Adiado'].includes(status))
                            continue;
                        writes.push(upsert('matches', 'cfmatch:' + c.tournament + ':' + c.season_id + ':' + m.id, { tournament_id: c.tournament, season_id: c.season_id, home_id: home, away_id: away, round: index, phase: stage.title || 'Copa Fácil', kickoff: null, status, home_score: Number.isInteger(m.result?.pts1) ? m.result.pts1 : null, away_score: Number.isInteger(m.result?.pts2) ? m.result.pts2 : null, notes: `Rodada: ${round.title}. Status na origem: ${m.status}` }, 'copafacil'));
                    }
                }
            }
        }
        if (mods.includes('rankings')) {
            const rankings = await get('/rankings');
            cached('rankings', 'rankings', rankings);
            for (const rank of rankings)
                cached('ranking:' + rank.id, 'ranking', await get('/rankings/' + encodeURIComponent(rank.id)));
        }
        if (mods.includes('players')) {
            cached('playerkeys', 'playerkeys', await get('/players/keys'));
            const ids = new Set();
            for (const item of cache.filter(x => x.kind === 'table'))
                for (const t of item.data.teams || [])
                    if (t.id)
                        ids.add(t.id);
            if (ids.size)
                cached('players', 'players', await get('/players?' + [...ids].map(id => 'team=' + encodeURIComponent(id)).join('&')));
        }
        // A single transactional batch publishes the complete snapshot; failures keep the old cache intact.
        const refreshedKinds = ['stages', ...(mods.includes('table') ? ['table'] : []), ...(mods.includes('matches') ? ['rounds', 'matches'] : []), ...(mods.includes('rankings') ? ['rankings', 'ranking'] : []), ...(mods.includes('teams') ? ['teams', 'teamkeys'] : []), ...(mods.includes('players') ? ['players', 'playerkeys'] : [])];
        writes.push(db().prepare(`DELETE FROM external WHERE tournament_id=? AND (season_id=? OR season_id IS NULL AND ? IS NULL) AND kind IN (${refreshedKinds.map(() => '?').join(',')})`).bind(c.tournament, c.season_id || null, c.season_id || null, ...refreshedKinds));
        for (const item of cache)
            writes.push(db().prepare('INSERT INTO external(id,kind,data,updated_at,season_id,tournament_id) VALUES(?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET data=excluded.data,updated_at=excluded.updated_at').bind(c.tournament + ':' + (c.season_id || '') + ':' + item.id, item.kind, JSON.stringify(item.data), stamp, c.season_id || null, c.tournament));
        writes.push(setSetting('integration', { ...c, lastSync: stamp }), db().prepare('INSERT INTO sync_runs(id,status,message,created_at) VALUES(?,?,?,?)').bind(crypto.randomUUID(), 'Sucesso', `${count} consultas; ${cache.length} conjuntos atualizados.`, stamp));
        await db().batch(writes);
        return { ok: true, message: `Sincronização concluída: ${count} consultas.`, lastSync: stamp };
    }
    catch (e) {
        throw e;
    }
    finally {
        await db().prepare("UPDATE settings SET value='0' WHERE id='sync_lock'").run();
    }
}
export async function sync(test = false) { try {
    return await runSync(test);
}
catch (e) {
    await db().prepare('INSERT INTO sync_runs(id,status,message,created_at) VALUES(?,?,?,?)').bind(crypto.randomUUID(), 'Erro', String(e.message).slice(0, 500), new Date().toISOString()).run();
    throw e;
} }
