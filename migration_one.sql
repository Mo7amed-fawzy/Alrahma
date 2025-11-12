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









// supabase/functions/sync-release-link/index.ts
// Setup type definitions for Supabase runtime
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
console.info("sync-release-link function started");
Deno.serve(async (req)=>{
  try {
    if (req.method !== "POST") {
      return new Response("Method Not Allowed", {
        status: 405
      });
    }
    const body = await req.json().catch(()=>null);
    const tag = body?.tag;
    const token = body?.token; // GH token (fine-grained PAT) passed from GH Actions
    if (!tag) return new Response("Missing tag", {
      status: 400
    });
    if (!token) return new Response("Missing GitHub token", {
      status: 400
    });
    const OWNER = "Mo7amed-fawzy";
    const REPO = "Alrahma-CI-CD";
    // Supabase function secrets (set these when deploying the function)
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"); // service role secret
    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      return new Response("Missing Supabase env (SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY)", {
        status: 500
      });
    }
    // 1) Get release by tag from GitHub
    const relRes = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${tag}`, {
      headers: {
        "Authorization": `token ${token}`,
        "Accept": "application/vnd.github+json",
        "User-Agent": "sync-release-link-fn"
      }
    });
    if (!relRes.ok) {
      const txt = await relRes.text();
      return new Response(`Failed to fetch release: ${relRes.status} ${txt}`, {
        status: 502
      });
    }
    const release = await relRes.json();
    const asset = (release.assets || []).find((a)=>a.name && a.name.endsWith(".apk"));
    if (!asset) {
      return new Response("No APK asset found in release", {
        status: 404
      });
    }
    // const downloadUrl = asset.browser_download_url || asset.url;
    // Use browser_download_url (direct asset link)
    const downloadUrl = `https://ciikqcvwmhtnhisxigvh.supabase.co/functions/v1/download-apk?tag=${tag}&meta=false`;
    // compute integer version (use major component of tag, fallback to timestamp)
    const cleaned = (tag || "").replace(/^v/i, "");
    const major = parseInt(cleaned.split(".")[0] || "0", 10);
    const versionInt = Number.isInteger(major) && major > 0 ? major : Math.floor(Date.now() / 1000);
    // 2) Insert a new row into updates table (this will trigger your INSERT trigger -> realtime broadcast)
    const insertRes = await fetch(`${SUPABASE_URL.replace(/\/$/, "")}/rest/v1/updates`, {
      method: "POST",
      headers: {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
        "Prefer": "return=representation"
      },
      body: JSON.stringify({
        version: versionInt,
        apk_url: downloadUrl,
        force_update: false
      })
    });
    if (!insertRes.ok) {
      const txt = await insertRes.text();
      return new Response(`Failed to insert update: ${insertRes.status} ${txt}`, {
        status: 502
      });
    }
    const inserted = await insertRes.json(); // array of rows returned
    const newId = inserted && inserted[0] && inserted[0].id;
    // 3) Keep only the most recent row (optional housekeeping) => delete older rows except the newly inserted one
    if (newId) {
      // delete all rows where id != newId
      await fetch(`${SUPABASE_URL.replace(/\/$/, "")}/rest/v1/updates?id=not.eq.${newId}`, {
        method: "DELETE",
        headers: {
          "apikey": SUPABASE_SERVICE_ROLE_KEY,
          "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
          "Prefer": "return=minimal"
        }
      });
    }
    const publicUrl = downloadUrl; // we don't upload to Supabase Storage; use GitHub release link
    return new Response(JSON.stringify({
      ok: true,
      url: publicUrl,
      version: versionInt
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json"
      }
    });
  } catch (err) {
    return new Response("Error: " + String(err), {
      status: 500
    });
  }
});





import "jsr:@supabase/functions-js/edge-runtime.d.ts";
Deno.serve(async (req)=>{
  try {
    if (req.method !== "GET") {
      return new Response("Method Not Allowed", {
        status: 405
      });
    }
    const OWNER = "Mo7amed-fawzy";
    const REPO = "Alrahma-CI-CD";
    const GH_TOKEN = Deno.env.get("GH_TOKEN");
    if (!GH_TOKEN) {
      return new Response("Missing GitHub token in environment", {
        status: 500
      });
    }
    const url = new URL(req.url);
    const tag = url.searchParams.get("tag");
    const metaOnly = url.searchParams.get("meta") === "true";
    // ✅ Get release (latest or specific tag)
    let release;
    if (tag) {
      const relRes = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${tag}`, {
        headers: {
          Authorization: `token ${GH_TOKEN}`,
          Accept: "application/vnd.github+json",
          "User-Agent": "download-apk-proxy-fn"
        }
      });
      if (!relRes.ok) {
        const txt = await relRes.text();
        return new Response(`Failed to fetch release: ${relRes.status} ${txt}`, {
          status: 502
        });
      }
      release = await relRes.json();
    } else {
      const latestRes = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/releases/latest`, {
        headers: {
          Authorization: `token ${GH_TOKEN}`,
          Accept: "application/vnd.github+json",
          "User-Agent": "download-apk-proxy-fn"
        }
      });
      if (!latestRes.ok) {
        const txt = await latestRes.text();
        return new Response(`Failed to fetch latest release: ${latestRes.status} ${txt}`, {
          status: 502
        });
      }
      release = await latestRes.json();
    }
    const asset = (release.assets || []).find((a)=>a.name && a.name.endsWith(".apk"));
    if (!asset) {
      return new Response("No APK asset found in release", {
        status: 404
      });
    }
    // ✅ لو المستخدم طالب meta فقط (JSON)
    if (metaOnly) {
      const baseUrl = req.url.replace(/\?.*$/, ""); // remove query
      const apkUrl = `${baseUrl}?tag=${release.tag_name}`;
      return new Response(JSON.stringify({
        version: release.tag_name,
        name: release.name,
        published_at: release.published_at,
        apk_url: apkUrl
      }), {
        status: 200,
        headers: {
          "Content-Type": "application/json"
        }
      });
    }
    // ✅ Otherwise: return APK file directly
    const apkRes = await fetch(asset.url, {
      headers: {
        Authorization: `token ${GH_TOKEN}`,
        Accept: "application/octet-stream"
      }
    });
    if (!apkRes.ok) {
      return new Response(`Failed to fetch APK: ${apkRes.status}`, {
        status: 502
      });
    }
    return new Response(apkRes.body, {
      status: 200,
      headers: {
        "Content-Type": "application/vnd.android.package-archive",
        "Content-Disposition": `attachment; filename="${asset.name}"`
      }
    });
  } catch (err) {
    return new Response("Error: " + String(err), {
      status: 500
    });
  }
});
