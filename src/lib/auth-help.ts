// Stable production origin: preview deployments must not receive account links.
export const AUTH_ORIGIN='https://efootball-brasileir-o.vercel.app';
export const authRedirect=(path:string)=>AUTH_ORIGIN+path;
export function authErrorMessage(error:any){
 const value=String(error?.code||error?.message||error||'').toLowerCase();
 if(/over_email_send_rate_limit|email rate limit|email.*rate.*exceed/.test(value))return 'O serviço de e-mail atingiu o limite de envios da liga. A solicitação de e-mail não foi concluída. A organização precisa liberar o envio; não crie outra conta nem peça vários links.';
 if(/provider.*(disabled|not.*enabled)|unsupported_provider/.test(value))return 'O acesso com Google ainda não está ativado pela organização.';
 if(/email_not_confirmed|email not confirmed/.test(value))return 'Seu e-mail ainda não foi confirmado. Abra o link mais recente recebido ou use Reenviar confirmação.';
 if(/invalid_credentials|invalid login credentials/.test(value))return 'E-mail ou senha incorretos. Se ainda não criou uma conta, escolha Primeiro acesso do participante.';
 if(/otp_expired|access_denied|expired|invalid.*link|bad_code_verifier/.test(value))return 'Este link é inválido, expirou ou já foi usado. Volte ao login e solicite um novo link uma única vez.';
 if(/user_already_exists|already registered/.test(value))return 'Este e-mail já tem cadastro. Use Entrar ou Recuperar senha.';
 if(/weak_password|password.*(short|least)|senha/.test(value))return 'Use uma senha com pelo menos 12 caracteres.';
 if(/rate_limit|rate limit|too many|429/.test(value))return 'Muitas tentativas em pouco tempo. Aguarde alguns minutos antes de tentar novamente.';
 if(/fetch|network|timeout/.test(value))return 'Falha de conexão. Confira sua internet e tente novamente.';
 return 'Não foi possível concluir o acesso. Tente novamente e, se continuar, avise a organização.';
}
export function authLinkError(search:string,hash:string){
 const q=new URLSearchParams(search),h=new URLSearchParams(hash.replace(/^#/,''));
 const code=q.get('error_code')||h.get('error_code')||q.get('error')||h.get('error');
 return code?authErrorMessage({code}):'';
}
