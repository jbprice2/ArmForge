-- Sessions: one per workout day
create table sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  date date not null,
  program_day int,
  arm_feel int check (arm_feel between 1 and 5),
  notes text,
  created_at timestamptz default now()
);

-- Throws: multiple distance/rep entries per session
create table throws (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references sessions on delete cascade,
  distance int not null,
  reps int not null,
  velocity int
);

-- Profiles (stores display name for each user)
create table profiles (
  id uuid references auth.users primary key,
  name text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Users can read all profiles"
  on profiles for select using (true);

create policy "Users can manage their own profile"
  on profiles for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Auto-create profile on signup
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name)
  values (new.id, new.raw_user_meta_data->>'name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- Teams
create table teams (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  join_code text unique not null,
  created_by uuid references auth.users,
  created_at timestamptz default now()
);

-- Team members
create table team_members (
  id uuid default gen_random_uuid() primary key,
  team_id uuid references teams on delete cascade,
  user_id uuid references auth.users on delete cascade,
  role text default 'player',
  joined_at timestamptz default now(),
  unique(team_id, user_id)
);

-- Row Level Security
alter table sessions enable row level security;
alter table throws enable row level security;

create policy "Users can manage their own sessions"
  on sessions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

alter table teams enable row level security;
alter table team_members enable row level security;

create policy "Anyone can read teams"
  on teams for select using (true);

create policy "Authenticated users can create teams"
  on teams for insert with check (auth.uid() = created_by);

create policy "Team creators can delete their team"
  on teams for delete using (auth.uid() = created_by);

create policy "Users can read team members"
  on team_members for select using (true);

create policy "Users can manage their own membership"
  on team_members for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage throws in their sessions"
  on throws for all
  using (
    session_id in (
      select id from sessions where user_id = auth.uid()
    )
  )
  with check (
    session_id in (
      select id from sessions where user_id = auth.uid()
    )
  );
