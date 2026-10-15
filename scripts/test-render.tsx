import React from 'react';
import {renderToString} from 'react-dom/server';
import assert from 'node:assert/strict';
import Portal from '../src/app/portal';
const paths=['/','/jogos','/semifinais','/apostas','/calendario','/jogos/ausente','/classificacao','/clubes','/clubes/ausente','/jogadores/ausente','/estatisticas','/noticias','/noticias/ausente','/videos','/videos/ausente','/museu','/temporadas/ausente','/premiacoes','/transferencias','/regulamento','/comparar','/admin','/recuperar-senha','/pagina-inexistente'];
for(const path of paths){const html=renderToString(<Portal path={path}/>);assert.ok(html.includes('BRASILEIRÃO'));assert.ok(!html.includes('npm start'));}
console.log(paths.length+' rotas renderizaram sem erro (estado inicial, não verificação visual).');
