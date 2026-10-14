import {build} from 'esbuild';
import {mkdtemp,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';
const dir=await mkdtemp(join(tmpdir(),'liga-render-'));
try{const out=join(dir,'test.mjs');await build({entryPoints:['scripts/test-render.tsx'],bundle:true,platform:'node',format:'esm',outfile:out,jsx:'automatic',define:{__SUPABASE_URL__:'""',__SUPABASE_KEY__:'""'},banner:{js:"import {createRequire} from 'node:module';const require=createRequire(import.meta.url);"}});await import(pathToFileURL(out).href);}finally{await rm(dir,{recursive:true,force:true});}
