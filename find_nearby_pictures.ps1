# === Parameters ===
$latitude = 49.00000000   # Target latitude
$longitude = 6.00000000 # Target longitude

$radiusMeters = 200            # Radius in meters
$city = "<todo>"       # City for initial sorting (optional, can be omitted)

$takenAfter = '2021-01-01'
$takenBefore = '2024-08-01'

# === Immich Login ===
# First, generate an access token in the Immich web interface (Profile -> API Keys)
#$server  = "https://your-immich.example.com"
#$token   = $env:IMMICH_TOKEN   # or as plain text string

#Connect-Immich -ServerUrl $server -AccessToken $token

# === Haversine distance in meters ===
function Get-DistanceMeters($lat1, $lon1, $lat2, $lon2) {
    $R = 6371000  # Earth radius in meters
    $phi1 = [math]::PI * $lat1 / 180
    $phi2 = [math]::PI * $lat2 / 180
    $deltaPhi = [math]::PI * ($lat2 - $lat1) / 180
    $deltaLambda = [math]::PI * ($lon2 - $lon1) / 180
    $a = [math]::Sin($deltaPhi / 2) * [math]::Sin($deltaPhi / 2) +
       [math]::Cos($phi1) * [math]::Cos($phi2) *
       [math]::Sin($deltaLambda / 2) * [math]::Sin($deltaLambda / 2)
    $c = 2 * [math]::Atan2([math]::Sqrt($a), [math]::Sqrt(1 - $a))
    return $R * $c
}

$matchedImages = @()

$results = Find-IMAsset -WithExif $true -City $city -takenAfter $takenAfter -takenBefore $takenBefore
foreach ($asset in $results) {
  $exif = $asset.exifInfo
  if ($exif -and $null -ne $exif.latitude -and $null -ne $exif.longitude -and $exif.lensmodel -notlike '*iPhone*') {
    $distance = Get-DistanceMeters $latitude $longitude $exif.latitude $exif.longitude
    if ($distance -le $radiusMeters ) { 
      $distance
      $matchedImages += $asset
    }
    else {
      #$distance
      #$exif.latitude
      #$exif.longitude
      #Read-Host
    }
  }
}

$matchedImages | Select-Object id, originalFileName, `
@{n = 'latitude'; e = { $_.exifInfo.latitude } }, `
@{n = 'longitude'; e = { $_.exifInfo.longitude } }, `
@{n = 'distance_m'; e = { [math]::Round((Get-DistanceMeters $latitude $longitude $_.exifInfo.latitude $_.exifInfo.longitude), 1) } }
