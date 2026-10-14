import { env } from './env.mjs';
import { getAuthenticatedUser } from './auth.mjs';
import { specs, youtubeId } from './model.mjs';
export function db() { const d = env.DB; if (!d)
    throw new Error('Banco de dados indisponível.'); return d; }
export async function rows(table) { return (await db().prepare(`SELECT * FROM ${table}`).all()).results; }
export async function setting(id, fallback = null) { const r = await db().prepare('SELECT value FROM settings WHERE id=?').bind(id).first(); try {
    return r ? JSON.parse(r.value) : fallback;
}
catch {
    return fallback;
} }
export function setSetting(id, value) { return db().prepare('INSERT INTO settings(id,value) VALUES(?,?) ON CONFLICT(id) DO UPDATE SET value=excluded.value').bind(id, JSON.stringify(value)); }
export async function identity() { const u = await getAuthenticatedUser(); if (!u)
    return null; let m = await db().prepare('SELECT * FROM members WHERE id=?').bind(u.userId).first(); if (!m && u.email) {
    const invite = await db().prepare('SELECT * FROM members WHERE email=? AND id LIKE ?').bind(u.email.toLowerCase(), 'invite:%').first();
    if (invite) {
        await db().prepare('UPDATE members SET id=? WHERE id=?').bind(u.userId, invite.id).run();
        m = { ...invite, id: u.userId };
    }
} return { ...u, role: m?.role || null }; }
export async function authorize(req, admin = false) { const origin = req.headers.get('origin'); if (origin && origin !== new URL(req.url).origin)
    throw new Error('Origem não autorizada.'); const u = await identity(); if (!u?.role || (admin && u.role !== 'admin'))
    throw new Error('Acesso não autorizado.'); return u; }
export function auditStmt(actor, action, entity, id = '') { return db().prepare('INSERT INTO audit(id,actor,action,entity,record_id,created_at) VALUES(?,?,?,?,?,?)').bind(crypto.randomUUID(), actor, action, entity, id, new Date().toISOString()); }
export function reply(data, status = 200) { return Response.json(data, { status, headers: { 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' } }); }
export function fail(e) { const message = String(e?.message || 'Falha inesperada.'); return reply({ error: message.includes('FOREIGN KEY') ? 'Este registro está vinculado a outros dados. Remova os vínculos antes de excluir.' : message.includes('UNIQUE') ? 'Já existe um registro com este vínculo.' : message }, message.includes('autorizad') ? 403 : 400); }
export async function validate(entity, raw, id) {
    const spec = specs[entity];
    if (!spec)
        throw new Error('Módulo inválido.');
    const data = {};
    for (const f of spec.fields) {
        let v = raw[f.key];
        if (v === '' || v === undefined)
            v = null;
        if (f.required && v == null)
            throw new Error(`${f.label} é obrigatório.`);
        if (v != null) {
            if (f.type === 'number') {
                v = Number(v);
                if (!Number.isFinite(v) || v < 0 || v > 1e12)
                    throw new Error(`${f.label} inválido.`);
                if (!['value', 'rating'].includes(f.key) && !Number.isInteger(v))
                    throw new Error(`${f.label} deve ser inteiro.`);
            }
            else {
                if (typeof v !== 'string' || v.length > (f.type === 'textarea' ? 40000 : 2000))
                    throw new Error(`${f.label} inválido.`);
                v = v.trim();
                if (f.required && !v)
                    throw new Error(`${f.label} é obrigatório.`);
            }
            if (f.options && !f.options.includes(v))
                throw new Error(`${f.label} inválido.`);
            if (f.ref && !await db().prepare(`SELECT id FROM ${f.ref} WHERE id=?`).bind(v).first())
                throw new Error(`${f.label} não encontrado.`);
            if (['image', 'url'].includes(f.type || '') && !/^https:\/\//.test(v) && !(f.type === 'image' && /^\/api\/media\/[\w.-]+$/.test(v)))
                throw new Error(`${f.label}: use uma URL HTTPS válida ou envie uma imagem.`);
        }
        data[f.key] = v;
    }
    if (data.kickoff && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(data.kickoff))
        data.kickoff += ':00-03:00';
    for (const key of ['kickoff', 'date', 'started', 'ended'])
        if (data[key] && !Number.isFinite(Date.parse(data[key])))
            throw new Error('Data inválida.');
    if (data.started && data.ended && data.started > data.ended)
        throw new Error('A saída deve ocorrer após a entrada.');
    if (entity === 'matches') {
        if (data.home_possession > 100 || data.away_possession > 100 || data.home_possession != null && data.away_possession != null && data.home_possession + data.away_possession !== 100)
            throw new Error('As posses de bola devem somar 100%.');
        for (const side of ['home', 'away'])
            if (data[side + '_shots'] != null && data[side + '_on_target'] > data[side + '_shots'])
                throw new Error('Finalizações no alvo não podem exceder as finalizações totais.');
    }
    if (data.overall > 110 || data.rating > 10)
        throw new Error('Overall deve ser até 110 e nota até 10.');
    if (data.home_id && data.home_id === data.away_id)
        throw new Error('Escolha dois clubes diferentes.');
    if (entity === 'matches' && data.status === 'Encerrado' && (data.home_score == null || data.away_score == null))
        throw new Error('Informe o placar final.');
    if (data.from_id && data.from_id === data.to_id)
        throw new Error('Origem e destino devem ser diferentes.');
    if (data.url && entity === 'videos' && !youtubeId(data.url) || data.video && !youtubeId(data.video))
        throw new Error('Informe um link válido do YouTube.');
    if (entity === 'banners' && data.url && !/^https:\/\//.test(data.url) && !/^\/(?!\/)/.test(data.url))
        throw new Error('Destino inválido.');
    if (entity === 'memberships' && !data.ended) {
        const conflict = await db().prepare('SELECT id FROM memberships WHERE player_id=? AND season_id=? AND ended IS NULL AND id<>?').bind(data.player_id, data.season_id, id).first();
        if (conflict)
            throw new Error('O jogador já tem um vínculo ativo nesta temporada. Use uma transferência.');
    }
    if (['events', 'appearances'].includes(entity)) {
        const m = await db().prepare('SELECT * FROM matches WHERE id=?').bind(data.match_id).first();
        if (![m.home_id, m.away_id].includes(data.club_id))
            throw new Error('O clube não participa desta partida.');
        if (data.assist_id && data.type !== 'Gol')
            throw new Error('Assistência só pode ser vinculada a um gol.');
        if (data.player_id && data.player_id === data.assist_id)
            throw new Error('O autor do gol não pode dar assistência a si mesmo.');
        for (const key of ['player_id', 'assist_id'])
            if (data[key]) {
                const vínculo = await db().prepare('SELECT id FROM memberships WHERE player_id=? AND club_id=? AND season_id=?').bind(data[key], data.club_id, m.season_id).first();
                if (!vínculo)
                    throw new Error('O jogador precisa estar vinculado ao clube e à temporada da partida.');
            }
    }
    return data;
}
export function upsert(entity, id, data, source = 'local') { const now = new Date().toISOString(), record = { id, source, created_at: now, updated_at: now, ...data }; const keys = Object.keys(record); return db().prepare(`INSERT INTO ${entity}(${keys.join(',')}) VALUES(${keys.map(() => '?').join(',')}) ON CONFLICT(id) DO UPDATE SET ${keys.filter(k => !['id', 'created_at'].includes(k)).map(k => `${k}=excluded.${k}`).join(',')}`).bind(...keys.map(k => record[k] ?? null)); }
