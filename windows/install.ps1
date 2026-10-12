#requires -Version 5.1
<#
Windows enterprise bootstrap, stage 1: WinLibs GCC, fzf, LazyGit.
Default: read-only plan. -Apply: explicit user-approved install.
No elevation, execution-policy changes, or security-control changes.
#>
[CmdletBinding()]
param(
    [switch]$Apply,
    [ValidateSet('All','GCC','fzf','LazyGit')]
    [string]$Component = 'All'
)
$ErrorActionPreference = 'Stop'

if ($null -eq $env:USERPROFILE -or $env:USERPROFILE -eq '') {
    throw 'USERPROFILE is unavailable.'
}
$manifest = Join-Path $PSScriptRoot 'versions.json'
if (-not (Test-Path -LiteralPath $manifest)) { throw "Missing manifest: $manifest" }
$data = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
$names = if ($Component -eq 'All') { @('WinLibs GCC','fzf','LazyGit') } else {
    switch ($Component) { 'GCC' { @('WinLibs GCC') } default { @($Component) } }
}
$apps = Join-Path $env:USERPROFILE 'apps'
$downloads = Join-Path $env:USERPROFILE 'Downloads'

foreach ($name in $names) {
    $pkg = $data.tools | Where-Object { $_.name -eq $name } | Select-Object -First 1
    if (-not $pkg -or -not $pkg.url -or -not $pkg.sha256) { throw "Missing pinned URL/SHA256 for $name" }
    switch ($name) {
        'WinLibs GCC' { $folder = 'winlibs-gcc'; $relativeExe = 'mingw64\bin\gcc.exe'; $relativeBin = 'mingw64\bin' }
        'fzf'        { $folder = 'fzf';         $relativeExe = 'fzf.exe';          $relativeBin = '' }
        'LazyGit'    { $folder = 'lazygit';     $relativeExe = 'lazygit.exe';      $relativeBin = '' }
    }
    $target = Join-Path $apps $folder
    $exe = Join-Path $target $relativeExe
    $bin = if ($relativeBin) { Join-Path $target $relativeBin } else { $target }
    if (Test-Path -LiteralPath $exe -PathType Leaf) {
        Write-Host "[PRESENT] $name : $exe" -ForegroundColor Green
        continue
    }
    Write-Host "[PLAN] $name -> $target"
    Write-Host "       Source: $($pkg.url)"
    Write-Host "       SHA256: $($pkg.sha256)"
    Write-Host "       User PATH directory: $bin"
    if (-not $Apply) { continue }
    Write-Host "Installing $name into user profile..." -ForegroundColor Cyan
    $zip = Join-Path $downloads ("gentleman-" + $folder + "-" + $pkg.version + ".zip")
    $staging = Join-Path $apps ($folder + '.staging')
    if (Test-Path -LiteralPath $target) {
        throw "Target exists but executable is missing: $target. Inspect it manually; no overwrite was attempted."
    }
    if (Test-Path -LiteralPath $staging) {
        throw "Staging exists: $staging. Inspect it manually; no removal was attempted."
    }
    New-Item -ItemType Directory -Path $apps -Force | Out-Null
    New-Item -ItemType Directory -Path $downloads -Force | Out-Null
    if (-not (Test-Path -LiteralPath $zip -PathType Leaf)) {
        Invoke-WebRequest -Uri $pkg.url -OutFile $zip -UseBasicParsing
    }
    $actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
    if ($actual -ine $pkg.sha256) {
        throw "Checksum mismatch for $zip. Expected $($pkg.sha256); found $actual. No extraction performed."
    }
    Expand-Archive -LiteralPath $zip -DestinationPath $staging -ErrorAction Stop
    if (-not (Test-Path -LiteralPath (Join-Path $staging $relativeExe) -PathType Leaf)) {
        throw "Expected executable missing from extracted archive: $relativeExe. Staging retained."
    }
    Move-Item -LiteralPath $staging -Destination $target -ErrorAction Stop
    $userPath = [Environment]::GetEnvironmentVariable('Path','User')
    $entries = @($userPath -split ';' | Where-Object { $_ })
    if ($entries -notcontains $bin) {
        [Environment]::SetEnvironmentVariable('Path', (($entries + $bin) -join ';'), 'User')
        Write-Host "[PATH] Added to user PATH: $bin" -ForegroundColor Green
    }
    Write-Host "[INSTALLED] $name. Open a new terminal to verify. No executable was auto-launched." -ForegroundColor Green
}
if (-not $Apply) {
    Write-Host 'PLAN ONLY. No files or settings were changed. Run with -Apply only after TI authorizes the packages.' -ForegroundColor Yellow
}
