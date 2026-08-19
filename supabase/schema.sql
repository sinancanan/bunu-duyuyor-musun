-- "Bunu duyuyor musun?" — bulut senkronizasyonu şeması.
--
-- Supabase panelinde: SQL Editor → New query → bu dosyanın tamamını yapıştır → Run.
-- Tek seferlik bir kurulumdur; tekrar çalıştırmak güvenlidir (IF NOT EXISTS / OR REPLACE).
--
-- Ne oluşturur:
--   - public.profiles: her kullanıcının tüm ilerlemesini (skorlar, işitme testi
--     geçmişi, ayarlar — index.html'deki `kayit` nesnesinin birebir aynısı)
--     tek bir jsonb sütununda tutan tablo.
--   - Row Level Security: her kullanıcı YALNIZCA kendi satırına okuma/yazma
--     erişimine sahiptir (auth.uid() = id). "anon public" API anahtarı bu
--     korumaya güvenerek istemci tarafında (index.html içinde) açıkça yer alır —
--     bu tasarım gereğidir, anahtarı gizlemene gerek yok. service_role
--     anahtarını ise hiçbir zaman istemci koduna koyma.

create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "kullanici kendi profilini okur" on public.profiles;
create policy "kullanici kendi profilini okur"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "kullanici kendi profilini olusturur" on public.profiles;
create policy "kullanici kendi profilini olusturur"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "kullanici kendi profilini gunceller" on public.profiles;
create policy "kullanici kendi profilini gunceller"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
