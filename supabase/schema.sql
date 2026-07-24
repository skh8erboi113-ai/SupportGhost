create extension if not exists pgcrypto;

create table if not exists stores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  shopify_domain text,
  access_token text,
  created_at timestamp default now()
);

create table if not exists orders_cache (
  id uuid primary key default gen_random_uuid(),
  shopify_order_id text,
  email text,
  status text,
  tracking text,
  created_at timestamp default now()
);

create index if not exists orders_cache_email_idx
  on orders_cache (email);

create table if not exists tickets (
  id uuid primary key default gen_random_uuid(),
  store_id uuid,
  email_from text,
  subject text,
  body text,
  drafted_reply text,
  status text default 'open',
  created_at timestamp default now()
);

alter table stores enable row level security;
alter table tickets enable row level security;
alter table orders_cache enable row level security;

create policy "allow all"
  on stores
  for all
  using (true)
  with check (true);

create policy "allow all"
  on tickets
  for all
  using (true)
  with check (true);

create policy "allow all"
  on orders_cache
  for all
  using (true)
  with check (true);
