function Find-ShortVideoPairs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        # Max allowed length in seconds (default: 5)
        [double]$MaxSeconds = 5,

        # Customize as needed
        [string[]]$ImageExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tif", ".tiff", ".heic", ".webp"),
        [string[]]$VideoExtensions = @(".mp4", ".mov", ".avi", ".mkv", ".wmv", ".flv", ".m4v", ".webm")
    )

    # --- ensure ffprobe is available ---
    $ffprobe = Get-Command ffprobe -ErrorAction SilentlyContinue
    if (-not $ffprobe) {
        throw "ffprobe not found. Please install FFmpeg (e.g. via Homebrew: 'brew install ffmpeg')."
    }

    function Get-VideoLengthSeconds {
        param([Parameter(Mandatory)][string]$FilePath)
        try {
            # prints raw seconds like "4.123456"
            $out = & $ffprobe.Source -v error -show_entries format=duration `
                   -of default=noprint_wrappers=1:nokey=1 -- $FilePath 2>$null
            if (-not $out) { return $null }
            $ci = [System.Globalization.CultureInfo]::InvariantCulture
            [double]::Parse($out.Trim(), $ci)
        } catch { $null }
    }

    $root = Resolve-Path -LiteralPath $Path -ErrorAction Stop

    # collect once (recursive)
    $allFiles = Get-ChildItem -Path $root -Recurse -File

    # images to check
    $images = $allFiles | Where-Object { $ImageExtensions -contains $_.Extension.ToLower() }

    foreach ($img in $images) {
        $dir  = $img.DirectoryName
        $base = [System.IO.Path]::GetFileNameWithoutExtension($img.Name)

        foreach ($vExt in $VideoExtensions) {
            $videoPath = Join-Path $dir ($base + $vExt)
            if (Test-Path -LiteralPath $videoPath) {
                $len = Get-VideoLengthSeconds -FilePath $videoPath
                write-host "Processing: $($img.Name)  -->  $([System.IO.Path]::GetFileName($videoPath)): $len sec"
                if ($null -ne $len -and $len -lt $MaxSeconds) {
                    [pscustomobject]@{
                        ImagePath = $img.FullName
                        VideoPath = (Resolve-Path -LiteralPath $videoPath).Path
                        VideoSec  = [math]::Round($len, 3)
                    }
                }
            }
        }
    }
}
