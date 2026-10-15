import React from 'react';
import {renderToStaticMarkup} from 'react-dom/server';
import assert from 'node:assert/strict';
import Semifinals from '../src/app/semifinals';
const clubs=[{id:'sp',name:'São Paulo',manager:'Swit'},{id:'pal',name:'Palmeiras',manager:'Jade'},{id:'san',name:'Santos',manager:'Paiiva'},{id:'cor',name:'Corinthians',manager:'Gusta'}];
const matches=[{id:'semi1',home_id:'sp',away_id:'pal',status:'Agendado'},{id:'semi2',home_id:'san',away_id:'cor',status:'Agendado'}];
const html=renderToStaticMarkup(<Semifinals clubs={clubs} matches={matches} season={{year:2026,name:'Brasileirão eFootball'}}/>);
for(const club of clubs){assert.ok(html.includes(club.name));assert.ok(html.includes('/clubes/'+club.id));}
for(const match of matches)assert.ok(html.includes('/jogos/'+match.id));
assert.ok(html.includes('Data e horário a definir'));assert.ok(html.includes('Vencedor da semifinal 1'));assert.ok(!html.includes('0 : 0'));
const finished=renderToStaticMarkup(<Semifinals clubs={clubs} matches={[{...matches[0],status:'Encerrado',home_score:3,away_score:2}]} season={{}}/>);assert.ok(finished.includes('3 : 2'));
console.log('Semifinais: clubes, links, agenda pendente, placares e final aguardando conferidos.');
