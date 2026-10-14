import { authorize, reply, fail, setting } from './server.mjs';
import { sync } from './copafacil.mjs';
export async function POST(req) { try {
    await authorize(req, true);
    const body = await req.json();
    if (body.action === 'auto') {
        const c = await setting('integration', {});
        if (!c.enabled || Date.now() - Date.parse(c.lastSync || '1970-01-01') < c.interval * 60000)
            return reply({ ok: true, skipped: true });
    }
    return reply(await sync(body.action === 'test'));
}
catch (e) {
    return fail(e);
} }
