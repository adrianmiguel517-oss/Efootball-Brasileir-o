import { authorize, db, rows, setting, setSetting, auditStmt, reply, fail, validate, upsert } from './server.mjs';
import { specs } from './model.mjs';
export async function POST(req) {
    try {
        if (Number(req.headers.get('content-length') || 0) > 200000)
            throw new Error('Requisição muito grande.');
        const body = await req.json();
        if (body.action === 'setup')
            throw new Error('Use a configuração de contas do portal.');
        const u = await authorize(req);
        const entity = body.entity;
        const id = body.id || crypto.randomUUID();
        if (['settings', 'member', 'remove-member', 'export'].includes(body.action) && u.role !== 'admin')
            throw new Error('Acesso não autorizado.');
        if (body.action === 'export') {
            const data = { exported_at: new Date().toISOString(), version: 1 };
            for (const key of Object.keys(specs))
                data[key] = await rows(key);
            data.audit = await rows('audit');
            return reply(data);
        }
        if (body.action === 'settings') {
            const c = body.data || {};
            const config = { tournament: String(c.tournament || '').slice(0, 100), mode: c.mode === 'external' ? 'external' : 'local', enabled: !!c.enabled, interval: Math.max(5, Math.min(1440, Number(c.interval) || 15)), modules: Array.isArray(c.modules) ? c.modules.filter((s) => ['stages', 'table', 'matches', 'rankings', 'teams', 'players'].includes(s)) : [], season_id: c.season_id || '', statusMap: typeof c.statusMap === 'object' ? c.statusMap : {}, lastSync: (await setting('integration', {})).lastSync || null };
            const batch = [setSetting('integration', config), auditStmt(u.userId, 'Configuração atualizada', 'integration')];
            if (body.apiKey) {
                if (typeof body.apiKey !== 'string' || body.apiKey.length > 500)
                    throw new Error('Chave inválida.');
                batch.push(setSetting('copafacil_key', body.apiKey.trim()));
            }
            await db().batch(batch);
            return reply({ ok: true });
        }
        if (body.action === 'member') {
            throw new Error('Use o gerenciamento local de contas.');
            const email = String(body.email || '').trim().toLowerCase();
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
                throw new Error('E-mail inválido.');
            const existing = await db().prepare('SELECT * FROM members WHERE email=?').bind(email).first();
            if (existing?.id === u.userId)
                throw new Error('Você não pode alterar sua própria permissão.');
            const role = body.role === 'admin' ? 'admin' : 'editor';
            await db().batch([db().prepare('INSERT INTO members(id,email,role) VALUES(?,?,?) ON CONFLICT(id) DO UPDATE SET role=excluded.role').bind(existing?.id || 'invite:' + crypto.randomUUID(), email, role), auditStmt(u.userId, 'Permissão atualizada', 'members', email)]);
            return reply({ ok: true });
        }
        if (body.action === 'remove-member') {
            if (id === u.userId)
                throw new Error('Você não pode remover seu próprio acesso.');
            await db().batch([db().prepare('DELETE FROM members WHERE id=?').bind(id), auditStmt(u.userId, 'Permissão removida', 'members', id)]);
            return reply({ ok: true });
        }
        if (!specs[entity])
            throw new Error('Módulo inválido.');
        if (u.role === 'editor' && !['news', 'videos', 'banners'].includes(entity))
            throw new Error('Acesso não autorizado.');
        const old = await db().prepare(`SELECT * FROM ${entity} WHERE id=?`).bind(id).first();
        if (old?.source === 'copafacil')
            throw new Error('Este registro é controlado pelo Copa Fácil. Altere na origem ou use dados locais.');
        if (body.action === 'delete') {
            if (old && entity === 'transfers' && old.status === 'Confirmada')
                throw new Error('Transferências confirmadas são históricas. Registre uma nova transferência para devolver o jogador.');
            await db().batch([db().prepare(`DELETE FROM ${entity} WHERE id=?`).bind(id), auditStmt(u.userId, 'Exclusão', entity, id)]);
            return reply({ ok: true });
        }
        if (body.action !== 'save')
            throw new Error('Ação inválida.');
        const data = await validate(entity, body.data || {}, id);
        if (old && entity === 'transfers' && old.status === 'Confirmada')
            throw new Error('Transferências confirmadas não podem ser alteradas. Registre uma nova negociação.');
        const batch = [upsert(entity, id, data), auditStmt(u.userId, old ? 'Edição' : 'Criação', entity, id)];
        if (entity === 'transfers' && data.status === 'Confirmada') {
            const current = await db().prepare('SELECT * FROM memberships WHERE player_id=? AND season_id=? AND ended IS NULL').bind(data.player_id, data.season_id).first();
            if (current && current.club_id !== data.from_id)
                throw new Error('O clube de origem difere do vínculo ativo.');
            if (!current && data.from_id)
                throw new Error('Cadastre o vínculo de origem antes de confirmar.');
            if (current)
                batch.push(db().prepare('UPDATE memberships SET ended=?,updated_at=? WHERE id=?').bind(data.date, new Date().toISOString(), current.id));
            batch.push(upsert('memberships', 'transfer:' + id, { season_id: data.season_id, club_id: data.to_id, player_id: data.player_id, role: 'Reserva', number: null, started: data.date, ended: null }));
        }
        await db().batch(batch);
        return reply({ ok: true, id });
    }
    catch (e) {
        return fail(e);
    }
}
