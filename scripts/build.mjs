import {build} from 'esbuild';
import {mkdir,copyFile,readFile,writeFile} from 'node:fs/promises';
const url=process.env.SUPABASE_URL||'',key=process.env.SUPABASE_PUBLISHABLE_KEY||'';
if(key.startsWith('sb_secret_'))throw new Error('Nunca use uma chave secreta no frontend.');
if(key.split('.').length===3){const claims=JSON.parse(Buffer.from(key.split('.')[1],'base64url'));if(claims.role!=='anon')throw new Error('Somente a chave pública anon é permitida no frontend.');}
if(url&&!/^https:\/\/[a-z0-9.-]+\/?$/i.test(url))throw new Error('SUPABASE_URL inválida.');
await mkdir('dist/assets',{recursive:true});
await build({entryPoints:['src/main.tsx'],bundle:true,minify:true,format:'iife',target:['es2020'],outfile:'dist/assets/app.js',jsx:'automatic',define:{'process.env.NODE_ENV':'"production"','__SUPABASE_URL__':JSON.stringify(url),'__SUPABASE_KEY__':JSON.stringify(key)},legalComments:'eof'});
for(const file of ['styles.css','logo.jpg'])await copyFile('assets/'+file,'dist/assets/'+file);
let html=(await readFile('index.html','utf8')).replace('<!-- BASE -->','<base href="/">');
const site=process.env.SITE_URL||'';
if(site&&/^https:\/\/[a-z0-9.-]+\/?$/i.test(site))html=html.replace('content="assets/logo.jpg"','content="'+site.replace(/\/$/,'')+'/assets/logo.jpg"');
await writeFile('dist/index.html',html);
console.log('Build estático concluído em dist/. '+(!url||!key?'Configure as variáveis públicas do Supabase para ligar o banco.':''));
