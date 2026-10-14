// Supabase Edge Function. No Copa Fácil credentials are shipped in the site bundle.
import {createClient} from 'npm:@supabase/supabase-js@2.117.3';
const db=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false}});
const unwrap=(r:any)=>{if(r.error)throw new Error(r.error.message);return r.data};
const cors={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization,x-client-info,apikey,content-type,x-cron-secret','Access-Control-Allow-Methods':'POST, OPTIONS'};
const reply=(data:any,status=200)=>new Response(JSON.stringify(data),{status,headers:{...cors,'Content-Type':'application/json'}});
Deno.serve(async(req)=>{
 if(req.method==='OPTIONS')return new Response('',{headers:cors});
 if(req.method!=='POST')return reply({error:'Método inválido'},405);
 let token:string|null=null;
 try{
 const scheduled=!!Deno.env.get('CRON_SECRET')&&req.headers.get('x-cron-secret')===Deno.env.get('CRON_SECRET');
 if(!scheduled){
 const jwt=req.headers.get('Authorization')?.replace(/^Bearer /,'')||'';
 if(!jwt)return reply({error:'Acesso negado'},403);
 const authResult=await db.auth.getUser(jwt);
 const user=authResult.data?.user;
 if(authResult.error||!user)return reply({error:'Acesso negado'},403);
 if(!user||unwrap(await db.from('members').select('role').eq('id',user.id).maybeSingle())?.role!=='admin')return reply({error:'Acesso negado'},403);
 }
 const raw=await req.text();
 if(raw.length>200000)return reply({error:'Requisição muito grande'},413);
 const body=JSON.parse(raw);
 let c=unwrap(await db.from('settings').select('value').eq('id','integration').single()).value;
 if(body.action==='settings'){
 if(scheduled)return reply({error:'Acesso negado'},403);
 const v=body.data||{};
 const statusMap=v.statusMap||{};
 if(Object.values(statusMap).some(x=>!['Agendado','Ao vivo','Encerrado','Adiado'].includes(String(x))))throw new Error('Mapa de status inválido');
 const hasKey=!!(body.apiKey||unwrap(await db.rpc('integration_secret')));
 const config={hasKey,tournament:String(v.tournament||'').slice(0,100),mode:v.mode==='external'?'external':'local',enabled:!!v.enabled,interval:Math.max(5,Math.min(1440,Number(v.interval)||15)),modules:Array.isArray(v.modules)?v.modules.filter((x:string)=>['stages','table','matches','rankings','teams','players'].includes(x)):[],season_id:v.season_id||null,statusMap,lastSync:c.lastSync||null,lastAttempt:c.lastAttempt||null};
 if(body.apiKey&&String(body.apiKey).length>500)throw new Error('Chave inválida');
 unwrap(await db.rpc('integration_config',{config,secret:body.apiKey||null}));
 return reply({ok:true});
 }
 if(!['test','sync'].includes(body.action))throw new Error('Ação inválida');
 if(scheduled&&(!c.enabled||Date.now()-new Date(c.lastAttempt||0).getTime()<Number(c.interval)*60000))return reply({ok:true,message:'Fora do intervalo configurado.'});
 token=unwrap(await db.rpc('integration_lock'));
 c=unwrap(await db.from('settings').select('value').eq('id','integration').single()).value;
 const key=unwrap(await db.rpc('integration_secret'));
 if(!key||!c.tournament)throw new Error('Configure a chave e o campeonato.');
 const base='https://copafacil.com/api2/tournament/'+encodeURIComponent(c.tournament);
 let count=0;const started=Date.now();
 async function get(path:string){if(++count>100||Date.now()-started>90000)throw new Error('Limite desta execução atingido; reduza os módulos selecionados.');const r=await fetch(base+path,{headers:{'x-api-key':key,lang:'pt',gmt:'-3'},signal:AbortSignal.timeout(10000)});if(!r.ok)throw new Error('Copa Fácil retornou HTTP '+r.status);return r.json()}
 const stages=await get('/stages');if(!Array.isArray(stages))throw new Error('Resposta inesperada para fases.');
 if(body.action==='test')return reply({ok:true,message:'Conexão confirmada: '+stages.length+' fase(s).'});
        const mods = c.modules || [], stamp = new Date().toISOString();
        const cache: {id:string;kind:string;data:any}[] = [];
        const writes = [];
        const upsert=(table:string,id:string,row:Record<string,unknown>,source:string)=>({table,row:{id,source,created_at:stamp,updated_at:stamp,...row}});
        const cached = (id:string, kind:string, data:any) => cache.push({ id, kind, data });
        cached('stages', 'stages', stages);
        const teamMap = new Map();
        const normalize = (n:string) => n.trim().toLocaleLowerCase('pt-BR');
        async function team(name:string, externalId?:string, photo?:string) { if (!name)
            throw new Error('Equipe sem nome recebida.'); const normalized = normalize(name); if (teamMap.has(normalized))
            return teamMap.get(normalized); const hash = Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(c.tournament + ':' + normalized)))).map(x => x.toString(16).padStart(2, '0')).join('').slice(0, 24); const id = 'cfclub:' + hash; teamMap.set(normalized, id); writes.push(upsert('clubs', id, { tournament_id: c.tournament, name, short: name.slice(0, 3).toUpperCase(), color: '#087750', image: photo && /^https:\/\//.test(photo) ? photo : null, manager: null, bio: null }, 'copafacil')); return id; }
        if (mods.includes('teams') || mods.includes('players')) {
            const teams = await get('/teams');
            cached('teams', 'teams', teams);
            cached('teamkeys', 'teamkeys', await get('/teams/keys'));
            for (const t of teams.teams || [])
                await team(t.name, t.id, t.photo);
        }
        for (const stage of stages) {
            const sid = encodeURIComponent(stage.id);
            const phaseId='cfphase:'+c.tournament+':'+c.season_id+':'+stage.id;
            if(mods.includes('stages')||mods.includes('matches')){if(!c.season_id)throw new Error('Selecione uma temporada.');writes.push(upsert('phases',phaseId,{season_id:c.season_id,name:stage.title||'Copa Fácil'},'copafacil'));}
            if (mods.includes('table')) {
                const table = await get('/stages/' + sid + '/table');
                cached('table:' + stage.id, 'table', { ...table, stageTitle: stage.title });
                for (const t of table.teams || [])
                    await team(t.name, t.id, t.photo);
            }
            if (mods.includes('matches')) {
                if (!c.season_id || !(await db.from('seasons').select('id').eq('id',c.season_id).maybeSingle()).data)
                    throw new Error('Selecione uma temporada local para vincular as partidas.');
                const rounds = await get('/stages/' + sid + '/rounds');
                cached('rounds:' + stage.id, 'rounds', { stage: stage.title, rounds });
                let index = 0;
                for (const round of rounds) {
                    index++;
                    const roundId='cfround:'+phaseId+':'+round.id;
                    writes.push(upsert('rounds',roundId,{phase_id:phaseId,number:index,name:round.title||String(index)},'copafacil'));
                    const games = await get('/stages/' + sid + '/rounds/' + encodeURIComponent(round.id) + '/matchs');
                    cached('matches:' + stage.id + ':' + round.id, 'matches', { stage: stage.title, round: round.title, matches: games });
                    for (const m of games) {
                        const home = await team(m.teams?.team_1?.name), away = await team(m.teams?.team_2?.name);
                        const status = c.statusMap?.[m.status];
                        if (!['Agendado', 'Ao vivo', 'Encerrado', 'Adiado'].includes(status))
                            continue;
                        writes.push(upsert('matches', 'cfmatch:' + c.tournament + ':' + c.season_id + ':' + m.id, { tournament_id: c.tournament, season_id: c.season_id, home_id: home, away_id: away, round_id:roundId, round: index, phase: stage.title || 'Copa Fácil', kickoff: null, status, home_score: Number.isInteger(m.result?.pts1) ? m.result.pts1 : null, away_score: Number.isInteger(m.result?.pts2) ? m.result.pts2 : null, notes: `Rodada: ${round.title}. Status na origem: ${m.status}` }, 'copafacil'));
                    }
                }
            }
        }
        if (mods.includes('rankings')) {
            const rankings = await get('/rankings');
            cached('rankings', 'rankings', rankings);
            for (const rank of rankings)
                cached('ranking:' + rank.id, 'ranking', await get('/rankings/' + encodeURIComponent(rank.id)));
        }
        if (mods.includes('players')) {
            cached('playerkeys', 'playerkeys', await get('/players/keys'));
            const ids = new Set<string>();
            for (const item of cache.filter(x => x.kind === 'table'))
                for (const t of item.data.teams || [])
                    if (t.id)
                        ids.add(t.id);
            if (ids.size)
                cached('players', 'players', await get('/players?' + [...ids].map(id => 'team=' + encodeURIComponent(id)).join('&')));
        }
        // A single transactional batch publishes the complete snapshot; failures keep the old cache intact.
        const refreshedKinds = ['stages', ...(mods.includes('table') ? ['table'] : []), ...(mods.includes('matches') ? ['rounds', 'matches'] : []), ...(mods.includes('rankings') ? ['rankings', 'ranking'] : []), ...(mods.includes('teams') ? ['teams', 'teamkeys'] : []), ...(mods.includes('players') ? ['players', 'playerkeys'] : [])];

        unwrap(await db.rpc('integration_commit',{token,records:writes,snapshots:cache,refreshed:refreshedKinds,tournament:c.tournament,season:c.season_id||null,request_count:count}));
        return reply({ok:true,message:'Sincronização concluída: '+count+' consultas.'});
 }catch(e){
 // Never log headers, API keys or upstream response bodies.
 const message=e instanceof Error?e.message:'Falha na integração';
 if(token)await db.from('sync_runs').insert({status:'Erro',message:message.slice(0,500)});
 return reply({error:message},400);
 }finally{if(token)await db.rpc('integration_unlock',{token});}
});
