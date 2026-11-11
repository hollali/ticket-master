-- Ticket Master schema for Supabase (Postgres)

create extension if not exists "uuid-ossp";

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  email text,
  role text default 'user',
  created_at timestamptz default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text,
  venue_name text,
  venue_city text,
  image_url text,
  start_time timestamptz,
  end_time timestamptz,
  status text default 'published'
);

create table if not exists public.ticket_tiers (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references public.events(id) on delete cascade,
  name text,
  price numeric,
  quantity int,
  available int
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  event_id uuid references public.events(id),
  status text default 'confirmed',
  total_amount numeric,
  created_at timestamptz default now(),
  event_title text,
  event_start timestamptz
);

create table if not exists public.booking_items (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references public.bookings(id) on delete cascade,
  tier_id uuid,
  quantity int,
  unit_price numeric
);

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references public.bookings(id) on delete cascade,
  tier_id uuid,
  code text,
  status text default 'valid',
  created_at timestamptz default now(),
  tier_name text
);

alter table public.users enable row level security;
alter table public.events enable row level security;
alter table public.ticket_tiers enable row level security;
alter table public.bookings enable row level security;
alter table public.booking_items enable row level security;
alter table public.tickets enable row level security;

-- public read for events and tiers
create policy "events are readable by everyone" on public.events for select using (true);
create policy "tiers are readable by everyone" on public.ticket_tiers for select using (true);

-- users manage own profile
create policy "users read own profile" on public.users for select using (auth.uid() = id);
create policy "users insert own profile" on public.users for insert with check (auth.uid() = id);
create policy "users update own profile" on public.users for update using (auth.uid() = id);

-- bookings own
create policy "users read own bookings" on public.bookings for select using (auth.uid() = user_id);
create policy "users insert own bookings" on public.bookings for insert with check (auth.uid() = user_id);

create policy "users read own booking items" on public.booking_items for select
  using (exists (select 1 from public.bookings b where b.id = booking_id and b.user_id = auth.uid()));
create policy "users insert own booking items" on public.booking_items for insert
  with check (exists (select 1 from public.bookings b where b.id = booking_id and b.user_id = auth.uid()));

create policy "users read own tickets" on public.tickets for select
  using (exists (select 1 from public.bookings b where b.id = booking_id and b.user_id = auth.uid()));
create policy "users insert own tickets" on public.tickets for insert
  with check (exists (select 1 from public.bookings b where b.id = booking_id and b.user_id = auth.uid()));

-- allow authenticated users to update tier availability (for booking)
create policy "authenticated update tiers" on public.ticket_tiers for update
  using (auth.role() = 'authenticated');
