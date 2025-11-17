create table public.updates (
  id bigint generated always as identity primary key,
  version integer not null,
  apk_url text not null,
  force_update boolean not null default false,
  created_at timestamp with time zone default now()
);

select realtime.broadcast(
  channel => 'app_updates',
  message => jsonb_build_object(
    'action', 'update_available',
    'version', 12,
    'url', 'https://YOUR_SUPABASE_URL/storage/v1/object/public/apk/app_v12.apk'
  )
);

SELECT * FROM pg_available_extensions WHERE name = 'realtime';

SELECT realtime.send(
  jsonb_build_object(
    'action', 'update_available',
    'version', 1,
    'url', 'https://ciikqcvwmhtnhisxigvh.supabase.co/storage/v1/object/public/apk/app_v1.apk'
  )::jsonb,
  'update',      -- event
  'app_updates', -- topic
  false          -- private (عادة false)
);

--CI/CD Actions
create or replace function public.broadcast_update_trigger()
returns trigger language plpgsql as $$
begin
  perform realtime.send(
    jsonb_build_object(
      'action', 'update_available',
      'version', NEW.version,
      'url', NEW.apk_url,
      'force', NEW.force_update
    )::jsonb,
    'update',
    'app_updates',
    false
  );
  return NEW;
end;
$$;


create trigger trg_broadcast_after_insert
after insert on public.updates
for each row
execute function public.broadcast_update_trigger();



-- ✅ بعد تنفيذهم هتقدر تعمل:
insert into public.updates (version, apk_url)
values (5, 'https://ciikqcvwmhtnhisxigvh.supabase.co/storage/v1/object/public/apk/app_v5.apk');


-- وكل الأجهزة المتصلة بقناة app_updates هتستقبل التحديث تلقائيًا بدون أي SELECT.


alter table public.updates
alter column version type text using version::text;






