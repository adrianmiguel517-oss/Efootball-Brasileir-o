import assert from 'node:assert/strict';
import {createClient} from '@supabase/supabase-js';
import {enterLeague} from '../src/lib/login-flow';
import {authRedirect} from '../src/lib/auth-help';

// Uses the real SDK with a controlled Auth transport; sends no real emails.
const origin='https://login-test.invalid';
const storageKey='liga-login-test';
const data=new Map<string,string>();
const storage={getItem:(k:string)=>data.get(k)??null,setItem:(k:string,v:string)=>{data.set(k,v)},removeItem:(k:string)=>{data.delete(k)}};
const calls:any[]=[];
let scenario='invalid';
const token=(label:string)=>Buffer.from('{}').toString('base64url')+'.'+Buffer.from(JSON.stringify({sub:'user-test',exp:Math.floor(Date.now()/1000)+3600,label})).toString('base64url')+'.test';
const user={id:'user-test',email:'responsavel@example.test',aud:'authenticated',role:'authenticated',email_confirmed_at:'2026-10-16T01:00:00Z',app_metadata:{provider:'email'},user_metadata:{},created_at:'2026-10-15T00:00:00Z'};
const session=(label:string)=>({access_token:token(label),refresh_token:'test-refresh',token_type:'bearer',expires_in:3600,expires_at:Math.floor(Date.now()/1000)+3600,user});
const transport=async(input:any,options:any={})=>{
 const url=new URL(String(input));const body=options.body?JSON.parse(options.body):null;calls.push({path:url.pathname,query:url.searchParams,body});
 if(url.pathname.endsWith('/token')){
  if(url.searchParams.get('grant_type')==='refresh_token')return Response.json(session('refreshed'));
  if(scenario==='invalid')return Response.json({error_code:'invalid_credentials',msg:'Invalid login credentials'},{status:400});
  if(scenario==='unconfirmed')return Response.json({error_code:'email_not_confirmed',msg:'Email not confirmed'},{status:400});
  return Response.json(session('signed-in'));
 }
 if(url.pathname.endsWith('/signup'))return Response.json({user:{...user,email_confirmed_at:null},session:null});
 if(url.pathname.endsWith('/user'))return Response.json(user);
 if(url.pathname.endsWith('/logout')||url.pathname.endsWith('/resend')||url.pathname.endsWith('/recover'))return Response.json({});
 throw Error('Unexpected request: '+url.pathname);
};
const makeClient=()=>createClient(origin,'test-public-key',{global:{fetch:transport},auth:{storage,storageKey,persistSession:true,autoRefreshToken:true,detectSessionInUrl:false}});
const clients:any[]=[];const client=makeClient();clients.push(client);
try{
 await assert.rejects(enterLeague(client,'login','  RESPONSAVEL@EXAMPLE.TEST  ','test-password-only'),(e:any)=>e.code==='invalid_credentials');
 assert.equal(calls.length,1);assert.equal(calls[0].query.get('grant_type'),'password');assert.equal(calls[0].body.email,user.email);
 scenario='unconfirmed';calls.length=0;
 await assert.rejects(enterLeague(client,'login',user.email,'test-password-only'),(e:any)=>e.code==='email_not_confirmed');assert.equal(calls.length,1);assert.ok(calls.every(c=>c.path.endsWith('/token')));
 calls.length=0;assert.equal(await enterLeague(client,'signup',user.email,'test-password-only'),'confirm-email');assert.equal(calls.length,1);assert.equal(calls[0].query.get('redirect_to'),authRedirect('/apostas'));
 scenario='valid';calls.length=0;
 assert.equal(await enterLeague(client,'login',user.email,'test-password-only'),'signed-in');assert.equal(calls.length,1);assert.ok(data.has(storageKey));assert.ok(!data.get(storageKey)!.includes('test-password-only'));
 const returning=makeClient();clients.push(returning);calls.length=0;
 assert.equal((await returning.auth.getSession()).data.session?.user.id,user.id);assert.equal(calls.length,0,'Reopening a saved session must not send emails or request login');
 const stored=JSON.parse(data.get(storageKey)!);stored.expires_at=Math.floor(Date.now()/1000)-30;data.set(storageKey,JSON.stringify(stored));
 const expired=makeClient();clients.push(expired);calls.length=0;
 const refreshed=await expired.auth.getSession();assert.equal(refreshed.data.session?.user.id,user.id);assert.ok(calls.some(c=>c.query.get('grant_type')==='refresh_token'));assert.ok(!calls.some(c=>/resend|signup|recover/.test(c.path)));
 calls.length=0;assert.equal((await expired.auth.resend({type:'signup',email:user.email,options:{emailRedirectTo:authRedirect('/apostas')}})).error,null);assert.equal(calls.length,1);assert.equal(calls[0].query.get('redirect_to'),authRedirect('/apostas'));
 calls.length=0;assert.equal((await expired.auth.resetPasswordForEmail(user.email,{redirectTo:authRedirect('/recuperar-senha')})).error,null);assert.equal(calls.length,1);assert.equal(calls[0].query.get('redirect_to'),authRedirect('/recuperar-senha'));
 assert.equal((await expired.auth.signOut({scope:'local'})).error,null);assert.equal((await expired.auth.getSession()).data.session,null);assert.ok(!data.has(storageKey));
 console.log('SDK Auth: senha incorreta, conta pendente, cadastro, login, normalização, sessão persistida, renovação, reenvio, recuperação e saída passaram. Transporte simulado; entrega SMTP não testada.');
}finally{for(const c of clients)c.auth.stopAutoRefresh();}
