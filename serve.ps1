# Tiny static file server for testing docs/ locally: http://localhost:8791
$root = Join-Path $PSScriptRoot "docs"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8791/")
$listener.Start()
Write-Output "Serving $root on http://localhost:8791/"
$types = @{ ".html"="text/html; charset=utf-8"; ".json"="application/json; charset=utf-8"; ".js"="text/javascript; charset=utf-8"; ".webmanifest"="application/manifest+json"; ".png"="image/png"; ".css"="text/css" }
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart("/")
  if ($path -eq "" -or $path.EndsWith("/")) { $path += "index.html" }
  $file = Join-Path $root $path
  $full = [System.IO.Path]::GetFullPath($file)
  if ($full.StartsWith($root) -and (Test-Path $full -PathType Leaf)) {
    $bytes = [System.IO.File]::ReadAllBytes($full)
    $ext = [System.IO.Path]::GetExtension($full)
    $ctx.Response.ContentType = $(if ($types.ContainsKey($ext)) { $types[$ext] } else { "application/octet-stream" })
    $ctx.Response.Headers.Add("Cache-Control", "no-store")
    $ctx.Response.ContentLength64 = $bytes.Length
    try { $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length) } catch {}
  } else { $ctx.Response.StatusCode = 404 }
  try { $ctx.Response.Close() } catch {}
}

