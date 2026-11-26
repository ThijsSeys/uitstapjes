# Koppelt vrij gelicentieerde foto's (Wikimedia Commons) aan tips in een editie, op basis van het tip-id.
# Gebruik: powershell -File tools\add-photos.ps1 docs\data\editions\2026-11-26.json
param([Parameter(Mandatory)][string]$Edition)
$ErrorActionPreference = "Stop"
$base = "https://thumb.wikimedia.org/wikipedia/commons/thumb/"
function P($path, $file, $credit, $license, $caption) {
  [ordered]@{
    src = $base + $path + "/" + $file + "/960px-" + $file
    credit = $credit; license = $license; caption = $caption; source = "Wikimedia Commons"
    page = "https://commons.wikimedia.org/wiki/File:" + [uri]::UnescapeDataString($file).Replace(" ", "_")
  }
}
$photos = @{
  "kerstmarkt-brugge"     = P "9/9c" "Bruges_Christmas_market_2013.jpg" "DimiTalen" "CC0" "Kerstmarkt met schaatsbaan op de Markt (2013)"
  "gentse-winterfeesten"  = P "3/31" "Christmas_market%2C_Korenmarkt%2C_Ghent%2C_2013.jpg" "DimiTalen" "CC0" "Kerstmarkt op de Korenmarkt (2013)"
  "sea-life-blankenberge" = P "8/86" "Sea_lion_show_at_the_observation_pool%2C_Sea_Life_Blankenberge%2C_2011.jpg" "DimiTalen" "CC0" "Zeeleeuwenshow (2011)"
  "zwin-natuur-park"      = P "b/b9" "Ciconia_ciconia_in_Zwin%2C_Belgium_%284%29.jpg" "Michiel Dumon" "CC BY-SA 3.0" "Ooievaar in het Zwin"
  "plopsaland-de-panne"   = P "1/10" "Wickieland_shops_and_restaurants%2C_Plopsaland_De_Panne%2C_2021.jpg" "DimiTalen" "CC0" "Wickieland (zomer 2021)"
  "bellewaerde-winter"    = P "8/82" "Swing_rides_in_Bellewaerde_16-08-2016_%28Be%29.jpg" ("Pierre Andr" + [char]0xE9 + " Leclercq") "CC BY 4.0" "Zweefmolen aan de ingang (zomer 2016)"
  "huis-van-alijn"        = P "0/08" "Huis_van_Alijn_straatkant_Kraanlei.jpg" "Huis van Alijn" "CC BY-SA 4.0" "Het museum aan de Kraanlei"
  "de-gavers-harelbeke"   = P "5/56" "De_Gavers_-_Harelbeke.jpg" "Spotter2" "CC BY-SA 4.0" "De Koutermolen in De Gavers"
}
$json = Get-Content -Raw -Encoding UTF8 $Edition | ConvertFrom-Json
$n = 0
foreach ($wk in $json.weekends) { foreach ($t in $wk.tips) {
  if ($photos.ContainsKey($t.id)) {
    if ($t.PSObject.Properties["photo"]) { $t.photo = $photos[$t.id] } else { $t | Add-Member -NotePropertyName photo -NotePropertyValue $photos[$t.id] }
    $n++
  }
} }
$out = $json | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText((Resolve-Path $Edition), $out, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "$n tips kregen een foto"
