import {DatabaseSync} from 'node:sqlite';
import {mkdirSync,readFileSync,writeFileSync,existsSync,readdirSync,chmodSync} from 'node:fs';
import {resolve,join,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
export const ROOT=resolve(dirname(fileURLToPath(import.meta.url)),'..');
export const DATA=resolve(process.env.DATA_DIR||join(ROOT,'data'));
mkdirSync(DATA,{recursive:true,mode:0o700});mkdirSync(join(DATA,'uploads'),{recursive:true,mode:0o700});
export const sql=new DatabaseSync(join(DATA,'liga.sqlite'));
sql.exec('PRAGMA foreign_keys=ON; PRAGMA journal_mode=WAL; PRAGMA busy_timeout=5000');
sql.exec('CREATE TABLE IF NOT EXISTS app_migrations(name TEXT PRIMARY KEY)');
for(const name of readdirSync(join(ROOT,'migrations')).filter(x=>x.endsWith('.sql')).sort()){if(!sql.prepare('SELECT name FROM app_migrations WHERE name=?').get(name)){sql.exec('BEGIN');try{sql.exec(readFileSync(join(ROOT,'migrations',name),'utf8'));sql.prepare('INSERT INTO app_migrations(name) VALUES(?)').run(name);sql.exec('COMMIT')}catch(e){sql.exec('ROLLBACK');throw e}}}
try{chmodSync(join(DATA,'liga.sqlite'),0o600)}catch{}
class Prepared{constructor(text,args=[]){this.text=text;this.args=args}bind(...args){return new Prepared(this.text,args)}first(){return sql.prepare(this.text).get(...this.args)||null}all(){return {results:sql.prepare(this.text).all(...this.args)}}run(){const r=sql.prepare(this.text).run(...this.args);return {meta:{changes:Number(r.changes)}}}}
export const env={DB:{prepare:text=>new Prepared(text),batch(statements){sql.exec('BEGIN');try{const result=statements.map(s=>s.run());sql.exec('COMMIT');return result}catch(e){sql.exec('ROLLBACK');throw e}}},BUCKET:{async put(id,bytes,options){if(!/^[\w.-]+$/.test(id))throw new Error('Arquivo inválido');writeFileSync(join(DATA,'uploads',id),bytes,{mode:0o600})},async get(id){if(!/^[\w.-]+$/.test(id)||!existsSync(join(DATA,'uploads',id)))return null;const body=readFileSync(join(DATA,'uploads',id));return {body,httpMetadata:{contentType:id.endsWith('.png')?'image/png':id.endsWith('.webp')?'image/webp':'image/jpeg'}}}}};
