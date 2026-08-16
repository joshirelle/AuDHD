# Binabawasan ang sukat ng asset images hanggang MAX_DIMENSION at isinusulat
# pabalik sa parehong file. Nananatiling PNG ang PNG para hindi masira ang alpha.
# Nababawi ang lahat sa pamamagitan ng: git checkout -- assets/

Add-Type -AssemblyName System.Drawing

$AssetsDir    = 'assets'
$MaxDimension = 1080

function Optimize-Image {
    param([System.IO.FileInfo] $File)

    $originalSize = $File.Length

    # Binabasa muna sa memory dahil hinaharangan ng System.Drawing ang file habang bukas.
    $bytes  = [System.IO.File]::ReadAllBytes($File.FullName)
    $stream = New-Object System.IO.MemoryStream(, $bytes)
    $image  = [System.Drawing.Image]::FromStream($stream)

    $width  = $image.Width
    $height = $image.Height

    if ($width -le $MaxDimension -and $height -le $MaxDimension) {
        $image.Dispose(); $stream.Dispose()
        Write-Host ("  {0,-20} {1}x{2}  laktaw (sapat na)" -f $File.Name, $width, $height)
        return [PSCustomObject]@{ Original = $originalSize; New = $originalSize }
    }

    if ($width -ge $height) {
        $newWidth  = $MaxDimension
        $newHeight = [int]([math]::Round($height * ($MaxDimension / $width)))
    } else {
        $newHeight = $MaxDimension
        $newWidth  = [int]([math]::Round($width * ($MaxDimension / $height)))
    }

    $bitmap   = New-Object System.Drawing.Bitmap($newWidth, $newHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode    = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)

    $graphics.Dispose()
    $image.Dispose()
    $stream.Dispose()

    $bitmap.Save($File.FullName, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()

    $newSize = (Get-Item $File.FullName).Length
    $saved   = (1 - ($newSize / $originalSize)) * 100

    Write-Host ("  {0,-20} {1}x{2} -> {3}x{4}   {5:N0} KB -> {6:N0} KB  ({7:N1}% bawas)" -f `
        $File.Name, $width, $height, $newWidth, $newHeight, ($originalSize / 1KB), ($newSize / 1KB), $saved)

    return [PSCustomObject]@{ Original = $originalSize; New = $newSize }
}

if (-not (Test-Path $AssetsDir)) {
    Write-Host "Hindi mahanap ang '$AssetsDir'. Patakbuhin ito sa root ng Flutter project."
    return
}

$files = Get-ChildItem $AssetsDir -Recurse -File -Include *.png, *.jpg, *.jpeg
if ($files.Count -eq 0) {
    Write-Host "Walang larawan sa '$AssetsDir'."
    return
}

Write-Host "Sinusuri ang $($files.Count) na larawan (max $MaxDimension px)...`n"

$totalOriginal = 0
$totalNew      = 0
foreach ($file in $files) {
    $result = Optimize-Image -File $file
    $totalOriginal += $result.Original
    $totalNew      += $result.New
}

$totalSaved = $totalOriginal - $totalNew
$percent    = if ($totalOriginal -gt 0) { ($totalSaved / $totalOriginal) * 100 } else { 0 }

Write-Host ""
Write-Host ("Bago:    {0:N2} MB" -f ($totalOriginal / 1MB))
Write-Host ("Ngayon:  {0:N2} MB" -f ($totalNew / 1MB))
Write-Host ("Natipid: {0:N2} MB ({1:N1}%)" -f ($totalSaved / 1MB), $percent)
