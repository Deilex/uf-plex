# === CONFIGURACIÓN ===
$torrentsPath = "D:\Torrent\GATE"                   # Ruta Torrent donde se encuentra la serie
$plexPath = "D:\Netflix\Anime\GATE\S01"                  # Ruta donde queremos que vaya.
$nombreSerie = "GATE"                                    # Nombre de la serie que estamos copiando.
$temporada = 1                                                # Número de temporada (entero)

# Validar rutas
if (!(Test-Path -LiteralPath $torrentsPath)) {
    Write-Host "❌ La ruta de torrents no existe: $torrentsPath"
    exit
}
if (!(Test-Path -LiteralPath $plexPath)) {
    Write-Host "📁 Creando carpeta destino: $plexPath"
    New-Item -ItemType Directory -Path $plexPath -Force | Out-Null
}

# Buscar archivos de vídeo (recursivo)
$videoFiles = Get-ChildItem -LiteralPath $torrentsPath -File -Include *.mkv, *.mp4, *.avi -Recurse

if ($videoFiles.Count -eq 0) {
    Write-Host "❌ No se encontraron archivos de vídeo en $torrentsPath"
    exit
} else {
    Write-Host "✅ Archivos encontrados: $($videoFiles.Count)"
}

# Crear enlaces duros (hardlinks)
$episodeNumber = 1
$temporadaString = "S{0:D2}" -f $temporada  # Formatear número temporada como S01, S02...

foreach ($file in $videoFiles) {
    # Formatear nombre episodio (p.ej. "New Game! - S01E01.mkv")
    $episodeName = "$nombreSerie - $temporadaString" + "E{0:D2}$($file.Extension)" -f $episodeNumber
    $targetPath = Join-Path $plexPath $episodeName

    Write-Host "🔗 Intentando crear enlace:"
    Write-Host "   Origen : $($file.FullName)"
    Write-Host "   Destino: $targetPath"

    if (!(Test-Path -LiteralPath $targetPath)) {
        $cmd = "cmd /c mklink /H `"$targetPath`" `"$($file.FullName)`""
        $resultado = Invoke-Expression $cmd
        Write-Host "📌 Resultado: $resultado"
    } else {
        Write-Host "⚠️ Ya existe: $targetPath"
    }

    $episodeNumber++
}


