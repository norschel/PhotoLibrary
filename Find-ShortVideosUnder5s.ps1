function Find-ShortVideosUnder5s {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Path,

        # Search subfolders? Default: no
        [switch]$Recurse,

        [string[]]$VideoExtensions = @(".mp4", ".mov", ".m4v", ".webm", ".mkv", ".avi", ".wmv", ".flv")
    )

    # Fixed threshold
    $ThresholdSec = 5.0

    # Check ffprobe
    $ffprobe = Get-Command ffprobe -ErrorAction SilentlyContinue
    if (-not $ffprobe) {
        throw "ffprobe not found. Please install FFmpeg (e.g. via Homebrew: brew install ffmpeg)."
    }

    function Get-VideoLengthSeconds {
        param([Parameter(Mandatory)][string]$FilePath)
        try {
            # returns e.g. "4.123456" or "N/A"
            $out = & $ffprobe.Source -v error -show_entries format=duration `
                   -of default=noprint_wrappers=1:nokey=1 -- $FilePath 2>$null
            if (-not $out) { return $null }
            $val = $out.Trim()
            if ($val -eq "N/A") { return $null }
            [double]::Parse($val, [System.Globalization.CultureInfo]::InvariantCulture)
        } catch { $null }
    }

    $root = Resolve-Path -LiteralPath $Path -ErrorAction Stop

    $gci = @{ Path = $root; File = $true }
    if ($Recurse) { $gci.Recurse = $true }

    Get-ChildItem @gci |
        Where-Object { $VideoExtensions -contains $_.Extension.ToLower() } |
        ForEach-Object {
            $len = Get-VideoLengthSeconds -FilePath $_.FullName
            if ($len -ne $null -and $len -lt $ThresholdSec) {
                [pscustomobject]@{
                    VideoPath = $_.FullName
                    VideoSec  = [math]::Round($len, 3)
                    SizeBytes = $_.Length
                    Modified  = $_.LastWriteTime
                }
            }
        }
}
