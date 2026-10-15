import {createClient} from '@supabase/supabase-js';
import {specs,youtubeId} from './model';
import {authLinkError} from './auth-help';
export const initialAuthError=typeof location==='undefined'?'':authLinkError(location.search,location.hash);
declare const __SUPABASE_URL__:string;
declare const __SUPABASE_KEY__:string;
export const configured=!!(__SUPABASE_URL__&&__SUPABASE_KEY__);
export const supabase=configured?createClient(__SUPABASE_URL__,__SUPABASE_KEY__):null;
const unwrap=(r:any)=>{if(r.error)throw new Error(r.error.message);return r.data};
async function rows(table:string){const all:any[]=[];for(let offset=0;;offset+=500){const page=unwrap(await supabase!.from(table).select('*').order('id').range(offset,offset+499))||[];all.push(...page);if(page.length<500)return all;}}
async function loadData(admin:boolean){
 const user=(await supabase!.auth.getUser()).data.user;
 const member=user?unwrap(await supabase!.from('members').select('*').eq('id',user.id).maybeSingle()):null;
 const data:any=Object.fromEntries(await Promise.all(Object.keys(specs).map(async k=>[k,await rows(k)])));
 // RLS protects drafts; an authenticated editor visiting the public portal also sees only published content.
 if(!admin)for(const k of ['news','videos','banners'])data[k]=data[k].filter((x:any)=>x.status==='Publicado');
 data.user=user?{id:user.id,email:user.email,role:member?.role}:null;
 data.needsSetup=false;data.serverScheduler=false;
 data.config=unwrap(await supabase!.from('settings').select('value').eq('id','integration').maybeSingle())?.value||{mode:'local'};
 data.hasKey=!!data.config?.hasKey;
 data.external=await rows('external');
 if(admin&&member?.role==='admin'){
 data.logs=unwrap(await supabase!.from('audit').select('*').order('created_at',{ascending:false}).limit(200));
 data.syncRuns=unwrap(await supabase!.from('sync_runs').select('*').order('created_at',{ascending:false}).limit(50));
 data.members=await rows('members');
 }
 return data;
}
export async function apiFetch(path:string,options:any={}):Promise<Response>{
 try{
 if(!supabase)throw new Error('A conexão com Supabase ainda não foi configurada. Defina SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY na Vercel e publique novamente uma vez.');
 const body=typeof options.body==='string'?JSON.parse(options.body):options.body;
 let result:any={ok:true};
 if(path.startsWith('/api/data'))result=await loadData(path.includes('admin=1'));
 else if(path==='/api/auth'){
 if(body.action==='login')unwrap(await supabase.auth.signInWithPassword({email:body.email,password:body.password}));
 else if(body.action==='logout')unwrap(await supabase.auth.signOut());
 else if(body.action==='change-password'){
 const user=unwrap(await supabase.auth.getUser())?.user;
 if(!user?.email)throw new Error('Entre novamente.');
 unwrap(await supabase.auth.signInWithPassword({email:user.email,password:body.oldPassword}));
 unwrap(await supabase.auth.updateUser({password:body.newPassword}));
 unwrap(await supabase.auth.signOut({scope:'others'}));
 }else throw new Error('Ação de conta inválida.');
 }else if(path==='/api/upload'){
 const file=body.get('file') as File;
 if(!file||!['image/jpeg','image/png','image/webp'].includes(file.type)||file.size>5*1024*1024)throw new Error('Envie JPG, PNG ou WebP de até 5 MB.');
 const filename=crypto.randomUUID()+'.'+({'image/jpeg':'jpg','image/png':'png','image/webp':'webp'}[file.type]);
 unwrap(await supabase.storage.from('liga-images').upload(filename,file,{contentType:file.type,upsert:false}));
 result={url:supabase.storage.from('liga-images').getPublicUrl(filename).data.publicUrl};
 }else if(path==='/api/sync'||body?.action==='settings'){
 const r=await supabase.functions.invoke('copafacil',{body});
 if(r.error){let message='Não foi possível chamar a integração. Confira a publicação da Edge Function no Supabase.';try{message=(await r.error.context.json()).error||message}catch{}throw new Error(message)}
 if(r.data?.error)throw new Error(r.data.error);result=r.data;
 }else if(path==='/api/admin'){
 if(body.action==='export'){
 const data=await loadData(true);if(data.user?.role!=='admin')throw new Error('Acesso negado');
 result={exported_at:new Date().toISOString(),version:2,...Object.fromEntries(Object.keys(specs).map(k=>[k,data[k]])),audit:data.logs};
 result.audit=await rows('audit');
 result.virtualBet=Object.fromEntries(await Promise.all(['bet_wallets','bet_markets','bet_tickets','bet_withdrawals','bet_ledger'].map(async k=>[k,await rows(k)])));
 result.version=3;
 }else if(body.action==='member')unwrap(await supabase.rpc('authorize_member',{member_email:body.email,member_role:body.role}));
 else if(body.action==='remove-member')unwrap(await supabase.rpc('remove_member',{member_id:body.id}));
 else {
 const spec=specs[body.entity];if(!spec)throw new Error('Módulo inválido');
 if(body.action==='delete'){
 const deleted=unwrap(await supabase.from(body.entity).delete().eq('id',body.id).select('id'));
 if(!deleted?.length)throw new Error('Registro não encontrado ou exclusão não autorizada.');
 }else if(body.action==='save'){
 const row:any={id:body.id||crypto.randomUUID()};
 for(const f of spec.fields){const v=body.data[f.key];if(f.required&&(v===''||v==null))throw new Error('Preencha '+f.label);row[f.key]=v===''||v==null?null:f.type==='number'?Number(v):f.type==='datetime-local'?new Date(v).toISOString():String(v);if(f.type==='number'&&row[f.key]!=null&&!Number.isFinite(row[f.key]))throw new Error('Número inválido em '+f.label);}
 if(body.entity==='videos'&&!youtubeId(row.url))throw new Error('Informe um link válido do YouTube.');
 // The database fills these from the selected round and enforces season consistency.
 if(body.entity==='matches'){row.round=0;row.phase='Rodada';}
 unwrap(await supabase.from(body.entity).upsert(row).select('id').single());result={ok:true,id:row.id};
 }else throw new Error('Ação inválida');
 }
 }else throw new Error('Rota indisponível');
 return Response.json(result);
 }catch(e:any){return Response.json({error:e.message||'Não foi possível concluir.'},{status:400})}
}
export function subscribeChanges(callback:()=>void){
 if(!supabase)return()=>{};
 // Polling works without enabling Realtime replication and without keeping an admin session open.
 const timer=setInterval(()=>{if(document.visibilityState==='visible')callback()},30000);
 const authTimers=new Set<ReturnType<typeof setTimeout>>();
 const authListener=supabase.auth.onAuthStateChange(()=>{const t=setTimeout(()=>{authTimers.delete(t);callback()},0);authTimers.add(t)});
 const focus=()=>{if(document.visibilityState==='visible')callback()};
 document.addEventListener('visibilitychange',focus);window.addEventListener('online',focus);
 return()=>{clearInterval(timer);authListener.data.subscription.unsubscribe();for(const t of authTimers)clearTimeout(t);document.removeEventListener('visibilitychange',focus);window.removeEventListener('online',focus)};
}
