# PhotoLibrary

A collection of PowerShell scripts for managing and organizing a personal photo/video library (IMMICH).

## Prerequisites

- **PowerShell** (cross-platform: Windows, macOS, Linux)
- **[FFmpeg](https://ffmpeg.org/)** (`ffprobe`) – required by the video-related scripts  
  Install on macOS: `brew install ffmpeg`
- **[Immich PowerShell module](https://github.com/ImmichFrame/ImmichFrame)** – required by `find_nearby_pictures.ps1`

---

## Scripts

### `Find-ShortVideosUnder5s.ps1`

Defines the `Find-ShortVideosUnder5s` function. Scans a folder for video files shorter than 5 seconds and returns their path, duration, size, and last-modified date.

**Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `Path` | `string` | *(Mandatory)* Root folder to scan |
| `Recurse` | `switch` | Include subfolders |
| `VideoExtensions` | `string[]` | Extensions to check (default: `.mp4 .mov .m4v .webm .mkv .avi .wmv .flv`) |

**Example**

```powershell
. .\Find-ShortVideosUnder5s.ps1
Find-ShortVideosUnder5s -Path "D:\Videos" -Recurse
```

---

### `find-livephos.ps1`

Defines the `Find-ShortVideoPairs` function. Finds Live Photo–style pairs where an image file has a matching video file (same base name, same folder) and the video is shorter than a configurable threshold.

**Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `Path` | `string` | *(Mandatory)* Root folder to scan (recursive) |
| `MaxSeconds` | `double` | Maximum video length in seconds (default: `5`) |
| `ImageExtensions` | `string[]` | Image extensions to look for |
| `VideoExtensions` | `string[]` | Video extensions to match against |

**Example**

```powershell
. .\find-livephos.ps1
Find-ShortVideoPairs -Path "/Volumes/Photos" -MaxSeconds 3
```

---

### `find_nearby_pictures.ps1`

Queries an [Immich](https://immich.app/) instance for photos taken within a configurable radius of a GPS coordinate and within a date range. Uses the Haversine formula for distance calculation.

Edit the variables at the top of the script before running:

| Variable | Description |
|----------|-------------|
| `$latitude` / `$longitude` | Target GPS coordinate |
| `$radiusMeters` | Search radius in meters |
| `$city` | City hint for pre-filtering (optional) |
| `$takenAfter` / `$takenBefore` | Date range filter |

Uncomment and fill in `$server` and `$token` (or set the `IMMICH_TOKEN` environment variable), then call `Connect-Immich` before running the search.

**Example**

```powershell
$env:IMMICH_TOKEN = "your-api-key"
.\find_nearby_pictures.ps1
```

---

### `find_similar_files_name_size.ps1`

Compares two folders recursively, finds files with the same name, reports size differences, and **deletes** files from the target folder when they are identical in size to the source.

Edit the variables at the top:

| Variable | Description |
|----------|-------------|
| `$folder1` | Source folder path |
| `$folder2` | Target folder path |

> ⚠️ **Caution:** Files with matching names *and* sizes are permanently deleted from `$folder2`.

**Example**

```powershell
# Set $folder1 and $folder2 in the script, then run:
.\find_similar_files_name_size.ps1
```

---

## License

See [LICENSE](LICENSE).
