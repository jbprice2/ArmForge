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

-- Row Level Security
alter table sessions enable row level security;
alter table throws enable row level security;

create policy "Users can manage their own sessions"
  on sessions for all
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
