-- Registration does not grant administrative access, even with email confirmation disabled.
-- Existing member UUIDs and club owner UUIDs are preserved.
create or replace function private.bootstrap_verified_admin() returns trigger
language plpgsql security invoker set search_path='' as $$
begin
 return new;
end $$;
