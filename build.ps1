# Builds docs/index.html (the installable web app for GitHub Pages) from src/ and draws the app icons.
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$head = Get-Content -Raw -Encoding UTF8 (Join-Path $root "src\pwa-head.html")
$body = Get-Content -Raw -Encoding UTF8 (Join-Path $root "src\app.html")
$out = $head + $body + "`n</body>`n</html>`n"
[System.IO.File]::WriteAllText((Join-Path $root "docs\index.html"), $out, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "docs/index.html gebouwd"

$iconDir = Join-Path $root "docs\icons"
New-Item -ItemType Directory -Force $iconDir | Out-Null
Add-Type -AssemblyName System.Drawing

function New-Icon([int]$size, [string]$path, [bool]$maskable) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = "AntiAlias"; $g.TextRenderingHint = "AntiAliasGridFit"
  $rect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, ([System.Drawing.Color]::FromArgb(194, 87, 12)), ([System.Drawing.Color]::FromArgb(143, 61, 16)), 60
  if ($maskable) { $g.FillRectangle($brush, $rect) }
  else {
    $r = [int]($size * 0.22); $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc(0, 0, 2*$r, 2*$r, 180, 90); $p.AddArc($size-2*$r, 0, 2*$r, 2*$r, 270, 90)
    $p.AddArc($size-2*$r, $size-2*$r, 2*$r, 2*$r, 0, 90); $p.AddArc(0, $size-2*$r, 2*$r, 2*$r, 90, 90); $p.CloseFigure()
    $g.FillPath($brush, $p)
  }
  # Sun
  $sun = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 210, 120))
  $s = $size * 0.2; $g.FillEllipse($sun, [float]($size*0.62), [float]($size*0.16), [float]$s, [float]$s)
  # Rolling hills / road
  $hill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 255, 247, 239))
  $g.FillEllipse($hill, [float](-$size*0.2), [float]($size*0.72), [float]($size*1.4), [float]($size*0.7))
  # Letter
  $fontSize = if ($maskable) { $size * 0.42 } else { $size * 0.5 }
  $font = New-Object System.Drawing.Font "Segoe UI", ([float]$fontSize), ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = "Center"; $fmt.LineAlignment = "Center"
  $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 247, 239))
  $g.DrawString("U", $font, $white, (New-Object System.Drawing.RectangleF 0, ([float]($size*0.04)), $size, $size), $fmt)
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}
New-Icon 192 (Join-Path $iconDir "icon-192.png") $false
New-Icon 512 (Join-Path $iconDir "icon-512.png") $false
New-Icon 512 (Join-Path $iconDir "icon-maskable-512.png") $true
New-Icon 180 (Join-Path $iconDir "apple-touch-icon.png") $true
Write-Output "iconen getekend"
