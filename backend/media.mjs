import { env } from './env.mjs';
export async function GET(req, { params }) { const { id } = await params; if (!/^[\w.-]+$/.test(id))
    return new Response('Não encontrado', { status: 404 }); const o = await env.BUCKET.get(id); if (!o)
    return new Response('Não encontrado', { status: 404 }); return new Response(o.body, { headers: { 'Content-Type': o.httpMetadata?.contentType || 'image/png', 'Cache-Control': 'public,max-age=31536000,immutable', 'X-Content-Type-Options': 'nosniff' } }); }
