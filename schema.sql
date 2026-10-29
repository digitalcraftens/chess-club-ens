-- Chess Club ENS: run once in Supabase (SQL Editor). Creates tables, security rules and realtime.
create table public.profiles(id uuid primary key references auth.users(id) on delete cascade, username text unique not null, role text not null default 'student' check (role in ('student','admin')), created_at timestamptz default now());
create table public.games(id uuid primary key default gen_random_uuid(), w uuid references public.profiles(id) on delete set null, b uuid references public.profiles(id) on delete set null, fen text not null, moves jsonb not null default '[]', last jsonb, st text not null default 'open', res text not null default '', why text not null default '', ts bigint not null);
create table public.lessons(id uuid primary key default gen_random_uuid(), title text not null, body text not null, ts bigint not null);
create table public.sessions(id uuid primary key default gen_random_uuid(), title text not null, "when" text not null, url text not null check (url ~* '^https?://'), note text not null default '', ts bigint not null);

-- Every new account gets a profile. The username "admin" becomes the admin, but only ONCE:
-- create it yourself (README step 3) before publishing the site; afterwards the name is reserved.
create function public.new_user() returns trigger language plpgsql security definer set search_path=public as $$
declare u text := lower(split_part(new.email,'@',1)); r text := 'student';
begin
  if u = 'admin' then
    if exists(select 1 from profiles where role='admin') then raise exception 'reserved username'; end if;
    r := 'admin';
  end if;
  insert into profiles(id,username,role) values(new.id,u,r);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.new_user();

create function public.is_admin() returns boolean language sql stable security definer set search_path=public as
$$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;

alter table public.profiles enable row level security;
alter table public.games    enable row level security;
alter table public.lessons  enable row level security;
alter table public.sessions enable row level security;

-- Only logged-in users can read anything. Nobody can change roles from the browser.
create policy profiles_read on public.profiles for select to authenticated using (true);
create policy games_read    on public.games    for select to authenticated using (true);
create policy lessons_read  on public.lessons  for select to authenticated using (true);
create policy sessions_read on public.sessions for select to authenticated using (true);

-- Games: create your own, join an open one, move only in your own games.
create policy games_insert on public.games for insert to authenticated
  with check (st='open' and ((w=auth.uid() and b is null) or (b=auth.uid() and w is null)));
create policy games_update on public.games for update to authenticated
  using (w=auth.uid() or b=auth.uid() or (st='open' and (w is null or b is null)))
  with check (w=auth.uid() or b=auth.uid());
create policy games_delete on public.games for delete to authenticated
  using ((st='open' and (w=auth.uid() or b=auth.uid())) or public.is_admin());

-- Lessons and sessions: only the admin writes.
create policy lessons_admin  on public.lessons  for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy sessions_admin on public.sessions for all to authenticated using (public.is_admin()) with check (public.is_admin());

alter publication supabase_realtime add table public.games, public.lessons, public.sessions;
