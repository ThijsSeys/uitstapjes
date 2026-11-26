// Uitstapjes service worker: app shell from cache, tip data network-first (falls back to cache offline).
const CACHE = "uitstapjes-v2";
const SHELL = ["./", "./index.html", "./manifest.webmanifest", "./icons/icon-192.png", "./icons/icon-512.png"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET" || url.origin !== location.origin) return;
  const isData = url.pathname.includes("/data/");
  const isPage = e.request.mode === "navigate";
  if (isData || isPage) {
    // Network first so Monday's new edition shows up immediately; offline falls back to the last saved copy.
    e.respondWith(
      fetch(e.request)
        .then((res) => {
          if (res.ok) { const copy = res.clone(); caches.open(CACHE).then((c) => c.put(e.request, copy)); }
          return res;
        })
        .catch(() => caches.match(e.request, { ignoreSearch: true }).then((r) => {
          if (r) return r;
          // Only a page request may fall back to the app shell; data never gets HTML in place of JSON.
          if (isPage) return caches.match("./index.html");
          return new Response(JSON.stringify({ error: "offline" }), { status: 503, headers: { "Content-Type": "application/json" } });
        }))
    );
  } else {
    e.respondWith(caches.match(e.request).then((r) => r || fetch(e.request)));
  }
});
