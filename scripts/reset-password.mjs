import {createInterface} from 'node:readline/promises';
import {stdin,stdout} from 'node:process';
import {sql} from '../backend/env.mjs';
import {passwordHash} from '../backend/auth.mjs';
if(!stdin.isTTY){console.error('Execute este comando em um terminal interativo.');sql.close();process.exit(1)}
const rl=createInterface({input:stdin,output:stdout});
const email=(await rl.question('E-mail da conta: ')).trim().toLowerCase();rl.close();
const user=sql.prepare('SELECT id FROM auth_users WHERE email=?').get(email);
if(!user){console.error('Conta não encontrada. Conclua a configuração inicial primeiro.');sql.close();process.exit(1)}
async function hidden(prompt){stdout.write(prompt);stdin.setRawMode(true);stdin.resume();stdin.setEncoding('utf8');return new Promise((resolve,reject)=>{let value='';function clean(){stdin.off('data',listener);stdin.setRawMode(false);stdin.pause();stdout.write('\n')}function listener(chunk){for(const char of chunk){if(char==='\u0003'){clean();reject(new Error('Cancelado.'));return}if(char==='\r'||char==='\n'){clean();resolve(value);return}if(char==='\u007f'||char==='\b'){value=value.slice(0,-1);continue}if(char.charCodeAt(0)>=32&&value.length<128)value+=char}}stdin.on('data',listener)})}
try{const first=await hidden('Nova senha (mínimo 12 caracteres; digitação oculta): '),second=await hidden('Repita a senha: ');if(first!==second)throw new Error('As senhas não coincidem.');const hash=await passwordHash(first);sql.exec('BEGIN');try{sql.prepare('UPDATE auth_users SET password_hash=? WHERE id=?').run(hash,user.id);sql.prepare('DELETE FROM auth_sessions WHERE user_id=?').run(user.id);sql.exec('COMMIT')}catch(e){sql.exec('ROLLBACK');throw e}console.log('Senha atualizada. As sessões anteriores foram encerradas.')}catch(e){console.error(e.message);process.exitCode=1}finally{sql.close()}
