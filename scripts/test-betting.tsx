import React from 'react';
import {renderToStaticMarkup} from 'react-dom/server';
import assert from 'node:assert/strict';
import Betting from '../src/app/betting';
const d={user:null,seasons:[{id:'s',name:'Temporada',status:'Em andamento'}],clubs:[{id:'a',name:'Clube A',short:'A',source:'local'},{id:'b',name:'Clube B',short:'B',source:'local'}],matches:[{id:'m',season_id:'s',home_id:'a',away_id:'b',round:1,phase:'Semifinais',status:'Agendado',source:'local'}]};
const html=renderToStaticMarkup(<Betting d={d} seasonId="s" reload={async()=>{}}/>);
assert.ok(html.includes('Liga'));assert.ok(html.includes('15 Mi por temporada'));assert.ok(html.includes('Clube A'));assert.ok(html.includes('Clube B'));assert.ok(html.includes('Primeiro acesso do participante'));assert.ok(html.includes('Sem depósitos ou pagamentos em dinheiro real'));assert.ok(!html.includes('Gerenciar credenciais'));assert.ok(html.includes('disabled'));
console.log('Liga Bet: renderização pública, clubes, carteira virtual e acesso do participante conferidos.');
