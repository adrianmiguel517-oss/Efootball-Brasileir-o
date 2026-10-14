import { env } from './env.mjs';
import { authorize, reply, fail } from './server.mjs';
export async function POST(req) { try {
    await authorize(req);
    if (Number(req.headers.get('content-length') || 0) > 5.3e6)
        throw new Error('Limite de 5 MB por imagem.');
    const form = await req.formData();
    const f = form.get('file');
    if (!(f instanceof File) || f.size > 5e6)
        throw new Error('Envie uma imagem de até 5 MB.');
    const bytes = new Uint8Array(await f.arrayBuffer());
    const png = bytes[0] === 137 && bytes[1] === 80 && bytes[2] === 78 && bytes[3] === 71, jpg = bytes[0] === 255 && bytes[1] === 216 && bytes[2] === 255, webp = String.fromCharCode(...bytes.slice(0, 4)) === 'RIFF' && String.fromCharCode(...bytes.slice(8, 12)) === 'WEBP';
    if (!png && !jpg && !webp)
        throw new Error('Use PNG, JPG ou WebP.');
    const type = png ? 'image/png' : jpg ? 'image/jpeg' : 'image/webp';
    const id = crypto.randomUUID() + '.' + (png ? 'png' : jpg ? 'jpg' : 'webp');
    await env.BUCKET.put(id, bytes, { httpMetadata: { contentType: type } });
    return reply({ url: '/api/media/' + id });
}
catch (e) {
    return fail(e);
} }
