import {authRedirect} from './auth-help';

// A normal login never requests an email. Only creating an account does.
export async function enterLeague(client:any,mode:'login'|'signup',email:string,password:string){
 const credentials={email:email.trim().toLowerCase(),password};
 const result=mode==='signup'
  ?await client.auth.signUp({...credentials,options:{emailRedirectTo:authRedirect('/apostas')}})
  :await client.auth.signInWithPassword(credentials);
 if(result.error)throw result.error;
 if(result.data?.session)return 'signed-in' as const;
 if(mode==='signup')return 'confirm-email' as const;
 throw new Error('network');
}
