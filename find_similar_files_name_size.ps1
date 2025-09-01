$folder1 = "/Volumes/photo/"
$folder2 = "/Volumes/OneDrive/Bilder/Eigene Aufnahmen"

# Read files in both folders
$files1 = Get-ChildItem -Path $folder1 -File -Recurse | Where-Object { $_.FullName -notlike "$folder2*" }
$files2 = Get-ChildItem -Path $folder2 -File -Recurse

# Find common file names
$commonFiles = $files1 | Where-Object { $files2.Name -contains $_.Name }

# Prepare output
$result = foreach ($file in $commonFiles) {
    $matches = $files2 | Where-Object { $_.Name -eq $file.Name }
    foreach ($match in $matches) {
        [PSCustomObject]@{
            FileName      = $file.Name
            SourceSize    = $file.Length
            TargetSize    = $match.Length
            SourcePath    = $file.FullName
            TargetPath    = $match.FullName
        }
    }
}

# Display nicely in a table
$result | Format-Table -AutoSize

# check if there are any common files with the same size
$sameSize = $result | Where-Object { $_.SourceSize -eq $_.TargetSize }
if ($sameSize) {
    Write-Host "`nFiles with the same size found:" -ForegroundColor Green
    $sameSize | Format-Table -AutoSize

    # delete files with the same size from the target folder
    foreach ($file in $sameSize) {
        Remove-Item -Path $file.TargetPath -Force
        Write-Host "Deleted: $($file.TargetPath)" -ForegroundColor Red
    }
}

# check if there are any differences in file sizes
$differences = $result | Where-Object { $_.SourceSize -ne $_.TargetSize }
if ($differences) {
    Write-Host "`nFiles with different sizes found:" -ForegroundColor Yellow
    $differences | Format-Table -AutoSize
} 
else {
    Write-Host "`nAll common files have the same size." -ForegroundColor Green
}
