import { rows, identity, setting, db, reply, fail } from './server.mjs';
import { specs } from './model.mjs';
export async function GET(req) {
    try {
        const user = await identity();
        const isAdmin = new URL(req.url).searchParams.get('admin') === '1' && !!user?.role;
        const data = {};
        for (const key of Object.keys(specs)) {
            data[key] = await rows(key);
            if (!isAdmin && ['news', 'videos', 'banners'].includes(key))
                data[key] = data[key].filter((x) => x.status === 'Publicado');
        }
        const config = await setting('integration', { mode: 'local', enabled: false, interval: 15, modules: ['stages', 'table', 'matches', 'rankings', 'teams', 'players'] });
        delete config.apiKey;
        data.config = config;
        data.serverScheduler = true;
        data.user = user ? { id: user.userId, email: user.email, role: user.role } : null;
        data.needsSetup = !(await db().prepare('SELECT id FROM auth_users LIMIT 1').first());
        data.external = (await rows('external')).filter(x => isAdmin || ['table', 'ranking', 'matches'].includes(x.kind)).map(x => ({ ...x, data: JSON.parse(x.data) }));
        if (isAdmin) {
            data.logs = (await rows('audit')).sort((a, b) => b.created_at.localeCompare(a.created_at)).slice(0, 200);
            data.syncRuns = (await rows('sync_runs')).sort((a, b) => b.created_at.localeCompare(a.created_at)).slice(0, 50);
            data.hasKey = !!await setting('copafacil_key');
            data.members = user?.role === 'admin' ? await rows('members') : [];
        }
        return reply(data);
    }
    catch (e) {
        return fail(e);
    }
}
