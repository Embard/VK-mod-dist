param(
    [string]$Version = "1.0.1",
    [string]$RepoRawBaseUrl = "https://raw.githubusercontent.com/Embard/VK-mod-dist/main/latest",
    [string]$Notes = "Описание изменений"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root "package_source"
$latest = Join-Path $root "latest"
$zipName = "VK_Mods_update_$Version.zip"
$zipPath = Join-Path $latest $zipName
$manifestPath = Join-Path $latest "update.json"
$temp = Join-Path $root "_package_temp"

if (!(Test-Path $source)) {
    throw "Не найдена папка package_source"
}

$vkMod = Join-Path $source "VK_Mod.dll"
$vkCore = Join-Path $source "VK_Core.dll"
$icons = Join-Path $source "icons"

if (!(Test-Path $vkMod)) {
    throw "Не найден package_source\VK_Mod.dll"
}

if (!(Test-Path $vkCore)) {
    throw "Не найден package_source\VK_Core.dll"
}

if (!(Test-Path $icons)) {
    throw "Не найдена package_source\icons"
}

if (Test-Path $temp) {
    Remove-Item $temp -Recurse -Force
}

New-Item -ItemType Directory -Path $temp | Out-Null

Copy-Item $vkMod -Destination $temp
Copy-Item $vkCore -Destination $temp
Copy-Item $icons -Destination (Join-Path $temp "icons") -Recurse

$blacklist = Join-Path $source "blacklist.json"
if (Test-Path $blacklist) {
    Copy-Item $blacklist -Destination $temp
}

if (!(Test-Path $latest)) {
    New-Item -ItemType Directory -Path $latest | Out-Null
}

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path (Join-Path $temp "*") -DestinationPath $zipPath -Force

$sha = (Get-FileHash -Algorithm SHA256 -Path $zipPath).Hash.ToUpperInvariant()

$manifest = [ordered]@{
    version = $Version
    packageUrl = "$RepoRawBaseUrl/$zipName"
    sha256 = $sha
    notes = $Notes
    minLoaderVersion = "1.0.0"
}

$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8

Remove-Item $temp -Recurse -Force

Write-Host ""
Write-Host "Готово:"
Write-Host "  $zipPath"
Write-Host "  $manifestPath"
Write-Host ""
Write-Host "SHA-256:"
Write-Host "  $sha"
Write-Host ""
Write-Host "Теперь загрузи на GitHub в папку latest:"
Write-Host "  latest/update.json"
Write-Host "  latest/$zipName"
