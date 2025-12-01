import "jsr:@supabase/functions-js/edge-runtime.d.ts";
Deno.serve(async (req) => {
    try {
        // ✅ فقط POST
        if (req.method !== "POST") {
            return new Response("Method Not Allowed", {
                status: 405
            });
        }
        // ✅ تحقق من Authorization header الخاص بـ Supabase
        const authHeader = req.headers.get("Authorization");
        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return new Response("Missing or invalid authorization header", {
                status: 401
            });
        }
        const SUPABASE_SERVICE_ROLE_KEY = authHeader.replace("Bearer ", "");
        // ✅ جلب body
        const body = await req.json().catch(() => null);
        const tag = body?.tag;
        const githubToken = body?.token || Deno.env.get("GH_TOKEN"); // token خاص بـ GitHub API فقط
        if (!tag) return new Response("Missing tag", {
            status: 400
        });
        if (!githubToken) return new Response("Missing GitHub token", {
            status: 400
        });
        const OWNER = "Mo7amed-fawzy";
        const REPO = "Alrahma-CI-CD";
        const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
        if (!SUPABASE_URL) return new Response("Missing Supabase URL", {
            status: 500
        });
        // ✅ جلب Release من GitHub
        const relRes = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${tag}`, {
            headers: {
                Authorization: `token ${githubToken}`,
                Accept: "application/vnd.github+json",
                "User-Agent": "sync-apk-fn"
            }
        });
        if (!relRes.ok) {
            const txt = await relRes.text();
            return new Response(`Failed to fetch release: ${relRes.status} ${txt}`, {
                status: 502
            });
        }
        const release = await relRes.json();
        const asset = (release.assets || []).find((a) => a.name && a.name.endsWith(".apk"));
        if (!asset) return new Response("No APK asset found in release", {
            status: 404
        });
        // ✅ URL ثابت لتحميل آخر إصدار
        const apkProxyUrl = "https://iausrdtretepeivkajhn.supabase.co/functions/v1/download-apk?meta=false";
        // ✅ إدراج صف جديد لكل إصدار
        const insertRes = await fetch(`${SUPABASE_URL}/rest/v1/updates`, {
            method: "POST",
            headers: {
                apikey: SUPABASE_SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
                "Content-Type": "application/json",
                Prefer: "return=representation"
            },
            body: JSON.stringify({
                version: tag,
                apk_url: apkProxyUrl,
                force_update: false,
                created_at: new Date().toISOString()
            })
        });
        if (!insertRes.ok) {
            const txt = await insertRes.text();
            return new Response(`Failed to insert update: ${insertRes.status} ${txt}`, {
                status: 502
            });
        }
        const inserted = await insertRes.json();
        return new Response(JSON.stringify({
            ok: true,
            version: tag,
            apk_url: apkProxyUrl,
            inserted
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
