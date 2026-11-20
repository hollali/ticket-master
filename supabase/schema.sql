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


-- auto-create profile on signup (bypasses RLS)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, name, email, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', ''), new.email, 'user')
  on conflict (id) do update set
    name = excluded.name,
    email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- atomic booking creation
create or replace function public.create_booking(p_event_id uuid, p_items jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_event record;
  v_total numeric := 0;
  v_booking_id uuid;
  v_item jsonb;
  v_tier record;
  v_qty int;
  v_tier_id uuid;
  i int;
begin
  if v_user is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_event from public.events where id = p_event_id;
  if not found then
    raise exception 'Event not found';
  end if;

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_tier_id := (v_item->>'tierId')::uuid;
    v_qty := (v_item->>'quantity')::int;
    if v_qty is null or v_qty <= 0 then
      raise exception 'Invalid quantity';
    end if;
    select * into v_tier from public.ticket_tiers where id = v_tier_id for update;
    if not found then
      raise exception 'Tier not found';
    end if;
    if v_tier.event_id <> p_event_id then
      raise exception 'Tier does not belong to event';
    end if;
    if v_tier.available < v_qty then
      raise exception 'Not enough tickets available';
    end if;
    v_total := v_total + (v_tier.price * v_qty);
  end loop;

  insert into public.bookings (user_id, event_id, status, total_amount, event_title, event_start)
  values (v_user, p_event_id, 'confirmed', v_total, v_event.title, v_event.start_time)
  returning id into v_booking_id;

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_tier_id := (v_item->>'tierId')::uuid;
    v_qty := (v_item->>'quantity')::int;
    select * into v_tier from public.ticket_tiers where id = v_tier_id;
    update public.ticket_tiers set available = available - v_qty where id = v_tier_id;
    insert into public.booking_items (booking_id, tier_id, quantity, unit_price)
    values (v_booking_id, v_tier_id, v_qty, v_tier.price);
    for i in 1..v_qty loop
      insert into public.tickets (booking_id, tier_id, code, status, tier_name)
      values (v_booking_id, v_tier_id, upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)), 'valid', v_tier.name);
    end loop;
  end loop;

  return v_booking_id;
end;
$$;

grant execute on function public.create_booking(uuid, jsonb) to authenticated;
