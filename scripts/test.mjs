import assert from 'node:assert/strict';
import {mkdtempSync,rmSync,readFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {randomBytes} from 'node:crypto';
const dir=mkdtempSync(join(tmpdir(),'brasileirao-qa-'));
process.env.DATA_DIR=dir;process.env.SETUP_TOKEN=randomBytes(24).toString('hex');
const {createApp,scheduledTick}=await import('../server.mjs');
const {sql}=await import('../backend/env.mjs');
const server=createApp();await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));const base='http://127.0.0.1:'+server.address().port;
let cookie='',passed=0;
function check(condition,label){assert.ok(condition,label);passed++}
async function request(path,body,options={}){const r=await fetch(base+path,{method:body?'POST':'GET',headers:{...(body?{'Content-Type':'application/json',Origin:options.origin||base}:{}),...(cookie?{Cookie:cookie}:{}),...options.headers},...(body?{body:JSON.stringify(body)}:{})});const type=r.headers.get('content-type')||'';const data=type.includes('application/json')?await r.json():await r.text();if(options.setCookie&&r.headers.get('set-cookie'))cookie=r.headers.get('set-cookie').split(';')[0];return {r,data}}
async function save(entity,id,data){const r=await request('/api/admin',{action:'save',entity,id,data});assert.equal(r.data.ok,true,JSON.stringify(r.data));return r}
const passwordA='Teste-seguro-'+randomBytes(12).toString('hex'),passwordB='Teste-seguro-'+randomBytes(12).toString('hex');
try{
let r=await request('/');check(r.r.status===200&&r.data.includes('assets/app.js'),'Serves real index.html');
r=await request('/admin');check(r.r.status===200&&r.data.includes('noindex'),'Admin uses same HTML entry');
r=await request('/assets/app.js');check(r.r.status===200&&r.data.length>10000,'Bundled JavaScript exists');
r=await request('/api/data');check(r.data.needsSetup&&!r.data.user,'No public administrative identity');
r=await request('/api/admin',{action:'save',entity:'clubs',data:{name:'No',short:'N'}});check(r.r.status===403,'Anonymous write rejected');
r=await request('/api/auth',{action:'setup',code:'incorrect',passwords:{}});check(r.r.status===403,'Setup code protected');
r=await request('/api/auth',{action:'setup',code:process.env.SETUP_TOKEN,passwords:{'adrianmiguel517@gmail.com':passwordA,'paiivavitor07@gmail.com':passwordB}},{setCookie:true});check(r.data.ok,'Both admins initialized');check(r.r.headers.get('set-cookie').includes('HttpOnly')&&r.r.headers.get('set-cookie').includes('SameSite=Strict'),'Protected session cookie');
r=await request('/api/data?admin=1');check(r.data.user.email==='adrianmiguel517@gmail.com'&&r.data.user.role==='admin','Adrian authorized');check(r.data.members.some(m=>m.email==='paiivavitor07@gmail.com'&&m.role==='admin'),'Paiiva also admin');
check(!JSON.stringify(sql.prepare('SELECT * FROM auth_users').all()).includes(passwordA),'No plaintext password in database');
r=await request('/api/auth',{action:'setup',code:process.env.SETUP_TOKEN});check(r.r.status===409,'Setup cannot be repeated');
r=await request('/api/admin',{action:'export'},{origin:'https://other.test'});check(r.r.status===403,'CSRF origin rejected');
await save('seasons','s',{name:'Temporada de teste',year:2026,status:'Em andamento',tiebreakers:'points,wins,gd,gf'});
await save('clubs','home',{name:'Clube de teste A',short:'CTA'});await save('clubs','away',{name:'Clube de teste B',short:'CTB'});
await save('players','p',{name:'Atleta de teste',position:'CA',overall:90});await save('memberships','m',{season_id:'s',club_id:'home',player_id:'p',role:'Titular'});
await save('matches','g',{season_id:'s',home_id:'home',away_id:'away',round:1,phase:'Liga',status:'Encerrado',home_score:1,away_score:0});
const event={match_id:'g',club_id:'home',player_id:'p',type:'Gol',minute:15};await save('events','e',event);await save('events','e',event);check(sql.prepare('SELECT COUNT(*) AS n FROM events').get().n===1,'No duplicate event on retry');
await save('transfers','t',{season_id:'s',player_id:'p',from_id:'home',to_id:'away',date:'2026-10-14',status:'Confirmada'});check(sql.prepare('SELECT club_id FROM memberships WHERE player_id=? AND ended IS NULL').get('p').club_id==='away','Transfer updates roster atomically');
await save('news','draft',{title:'Draft',summary:'Not public',body:'**Bold**',author:'QA',category:'Comunicados',status:'Rascunho'});r=await request('/api/data');check(r.data.news.length===0,'Draft hidden from portal');
r=await request('/noticias/draft');check(r.r.status===404,'Draft deep link returns 404');
r=await request('/data/liga.sqlite');check(r.r.status===404&&!r.data.startsWith('SQLite'),'Database is not served publicly');
r=await request('/backend/auth.mjs');check(r.r.status===404&&!r.data.includes('passwordHash'),'Backend code not served');
const form=new FormData();form.set('file',new Blob([readFileSync(new URL('../assets/logo.jpg',import.meta.url))],{type:'image/png'}),'logo.png');let raw=await fetch(base+'/api/upload',{method:'POST',headers:{Cookie:cookie,Origin:base},body:form});const upload=await raw.json();check(raw.ok&&upload.url.startsWith('/api/media/'),'Real image upload');raw=await fetch(base+upload.url);check(raw.ok&&['image/png','image/jpeg'].includes(raw.headers.get('content-type')),'Uploaded image served: '+raw.status+' '+raw.headers.get('content-type')+' '+upload.url);
await request('/api/admin',{action:'settings',apiKey:'qa-secret-not-public',data:{tournament:'qa',mode:'local',modules:[],interval:5,enabled:false}});r=await request('/api/data');check(!JSON.stringify(r.data).includes('qa-secret-not-public'),'Copa Fácil key remains server-only');
await request('/api/auth',{action:'logout'},{setCookie:true});r=await request('/api/data');check(!r.data.user,'Logout clears access');
r=await request('/api/auth',{action:'login',email:'paiivavitor07@gmail.com',password:passwordB},{setCookie:true});check(r.data.ok,'Paiiva can log in');
r=await request('/api/data?admin=1');check(r.data.user.email==='paiivavitor07@gmail.com'&&r.data.user.role==='admin','Paiiva has admin permissions');
r=await request('/api/admin',{action:'member',email:'editor@example.com',role:'editor',temporaryPassword:passwordA});check(r.data.ok,'Editor account created with password');
await request('/api/auth',{action:'logout'},{setCookie:true});await request('/api/auth',{action:'login',email:'editor@example.com',password:passwordA},{setCookie:true});
r=await request('/api/admin',{action:'save',entity:'clubs',data:{name:'No',short:'N'}});check(r.r.status===403,'Editor cannot alter competition');
await save('news','published',{title:'Notícia de teste',summary:'Teste',body:'**Conteúdo**',author:'Editor',category:'Comunicados',status:'Publicado'});check(true,'Editor can publish content');
const newPassword='Nova-senha-'+randomBytes(12).toString('hex');r=await request('/api/auth',{action:'change-password',oldPassword:passwordA,newPassword},{setCookie:true});check(r.data.ok,'Password change works');
await request('/api/auth',{action:'logout'},{setCookie:true});r=await request('/api/auth',{action:'login',email:'editor@example.com',password:passwordA});check(r.r.status===401,'Old password rejected');
r=await request('/api/auth',{action:'login',email:'editor@example.com',password:newPassword},{setCookie:true});check(r.data.ok,'New password accepted');
const css=readFileSync(new URL('../assets/styles.css',import.meta.url),'utf8');check(css.includes('click-wave')&&css.includes('prefers-reduced-motion'),'Animations include reduced-motion support');
await scheduledTick();check(!sql.prepare('SELECT id FROM sync_runs').get(),'Disabled background sync is idle');
const integration=JSON.parse(sql.prepare('SELECT value FROM settings WHERE id=?').get('integration').value);sql.prepare('UPDATE settings SET value=? WHERE id=?').run(JSON.stringify({...integration,enabled:true}), 'integration');
const originalFetch=globalThis.fetch;globalThis.fetch=async url=>{assert.ok(String(url).startsWith('https://copafacil.com/api2/tournament/qa/'));return Response.json([])};
try{await scheduledTick();check(sql.prepare("SELECT COUNT(*) AS n FROM sync_runs WHERE status='Sucesso'").get().n===1,'Server scheduler runs with no browser connected');await scheduledTick();check(sql.prepare('SELECT COUNT(*) AS n FROM sync_runs').get().n===1,'Background scheduler respects interval');}finally{globalThis.fetch=originalFetch}

console.log(`PASSOU: ${passed} verificações de instalação, login dos dois admins, permissões, banco, transferências, arquivos e animações.`);
}finally{await new Promise(resolve=>server.close(resolve));sql.close();rmSync(dir,{recursive:true,force:true})}
