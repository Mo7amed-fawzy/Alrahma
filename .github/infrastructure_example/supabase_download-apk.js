import "jsr:@supabase/functions-js/edge-runtime.d.ts";
Deno.serve(async (req) => {
  try {
    if (req.method !== "GET") return new Response("Method Not Allowed", {
      status: 405
    });
    const OWNER = "Mo7amed-fawzy";
    const REPO = "Alrahma-CI-CD";
    const GH_TOKEN = Deno.env.get("GH_TOKEN");
    if (!GH_TOKEN) return new Response("Missing GitHub token in environment", {
      status: 500
    });
    const url = new URL(req.url);
    const tag = url.searchParams.get("tag");
    const metaOnly = url.searchParams.get("meta") === "true";
    let release;
    if (tag) {
      const r = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${tag}`, {
        headers: {
          Authorization: `token ${GH_TOKEN}`,
          Accept: "application/vnd.github+json",
          "User-Agent": "download-apk-fn"
        }
      });
      if (!r.ok) return new Response(`Failed to fetch release: ${r.status}`, {
        status: 502
      });
      release = await r.json();
    } else {
      const r = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/releases/latest`, {
        headers: {
          Authorization: `token ${GH_TOKEN}`,
          Accept: "application/vnd.github+json",
          "User-Agent": "download-apk-fn"
        }
      });
      if (!r.ok) return new Response(`Failed to fetch latest release: ${r.status}`, {
        status: 502
      });
      release = await r.json();
    }
    const asset = (release.assets || []).find((a) => a.name && a.name.endsWith(".apk"));
    if (!asset) return new Response("No APK asset found in release", {
      status: 404
    });
    if (metaOnly) {
      const baseUrl = req.url.replace(/\?.*$/, "");
      const apkUrl = `${baseUrl}?tag=${encodeURIComponent(release.tag_name)}&meta=false`;
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
    const apkRes = await fetch(asset.url, {
      headers: {
        Authorization: `token ${GH_TOKEN}`,
        Accept: "application/octet-stream"
      }
    });
    if (!apkRes.ok) return new Response(`Failed to fetch APK: ${apkRes.status}`, {
      status: 502
    });
    const headers = new Headers();
    const contentLength = apkRes.headers.get("content-length");
    const contentType = apkRes.headers.get("content-type") || "application/vnd.android.package-archive";
    const contentDisp = apkRes.headers.get("content-disposition") || `attachment; filename="${asset.name}"`;
    if (contentLength) headers.set("Content-Length", contentLength);
    headers.set("Content-Type", contentType);
    headers.set("Content-Disposition", contentDisp);
    return new Response(apkRes.body, {
      status: 200,
      headers
    });
  } catch (err) {
    return new Response("Error: " + String(err), {
      status: 500
    });
  }
});