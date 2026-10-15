import React,{useEffect,useState} from 'react';
import {googleLoginEnabled,supabase} from '../lib/api';
import {authErrorMessage,authRedirect} from '../lib/auth-help';

export const googleLoginOptions=(destination:'/admin'|'/apostas')=>({provider:'google' as const,options:{redirectTo:authRedirect(destination),queryParams:{prompt:'select_account'}}});

export default function GoogleLogin({destination='/apostas',disabled=false}:{destination?:'/admin'|'/apostas',disabled?:boolean}){
 const[enabled,setEnabled]=useState(false),[busy,setBusy]=useState(false),[error,setError]=useState('');
 useEffect(()=>{const controller=new AbortController();googleLoginEnabled(controller.signal).then(value=>{if(!controller.signal.aborted)setEnabled(value)}).catch(()=>{});return()=>controller.abort()},[]);
 if(!enabled)return null;
 async function enter(){if(busy||disabled)return;setBusy(true);setError('');try{if(!supabase)throw Error('network');const r=await supabase.auth.signInWithOAuth(googleLoginOptions(destination));if(r.error)throw r.error}catch(e){setError(authErrorMessage(e));setBusy(false)}}
 return <div className="google-login"><button className="button outline" type="button" onClick={enter} disabled={disabled||busy}><svg width="20" height="20" viewBox="0 0 48 48" aria-hidden="true"><path fill="#4285F4" d="M43.61 24.46c0-1.36-.12-2.65-.35-3.91H24v7.77h11a9.4 9.4 0 0 1-4.08 6.17v5.13h6.61c3.86-3.56 6.08-8.8 6.08-15.16Z"/><path fill="#34A853" d="M24 44c5.5 0 10.1-1.83 13.47-4.98l-6.61-5.13c-1.83 1.23-4.17 1.98-6.86 1.98-5.3 0-9.8-3.57-11.42-8.39H5.76v5.3A20.35 20.35 0 0 0 24 44Z"/><path fill="#FBBC05" d="M12.58 27.48a12.1 12.1 0 0 1 0-6.96v-5.3H5.76a20.2 20.2 0 0 0 0 17.56l6.82-5.3Z"/><path fill="#EA4335" d="M24 12.13c3 0 5.68 1.03 7.8 3.05l5.85-5.84A19.62 19.62 0 0 0 24 4 20.35 20.35 0 0 0 5.76 15.22l6.82 5.3C14.2 15.7 18.7 12.13 24 12.13Z"/></svg>{busy?'Abrindo Google…':'Entrar com Google'}</button><small>Escolha o mesmo e-mail vinculado ao seu clube. Sem esperar mensagem de confirmação da liga.</small>{error&&<p className="error-banner" role="alert">{error}</p>}<span className="google-login-divider">ou use e-mail e senha</span></div>
}
