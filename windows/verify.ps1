#requires -Version 5.1
# Read-only Windows environment report. No installation or configuration changes.
[CmdletBinding()]
param()
$tools = @(
  @{ Name='Git'; Command='git'; Args=@('--version') },
  @{ Name='Node.js'; Command='node'; Args=@('--version') },
  @{ Name='npm'; Command='npm.cmd'; Args=@('--version') },
  @{ Name='Go'; Command='go'; Args=@('version') },
  @{ Name='Neovim'; Command='nvim'; Args=@('--version') },
  @{ Name='ripgrep'; Command='rg'; Args=@('--version') },
  @{ Name='fd'; Command='fd'; Args=@('--version') },
  @{ Name='GCC'; Command='gcc'; Args=@('--version') },
  @{ Name='fzf'; Command='fzf'; Args=@('--version') },
  @{ Name='LazyGit'; Command='lazygit'; Args=@('--version') },
  @{ Name='Gentle Shell'; Command='gentle-shell.cmd'; Args=@('--version') }
)
Write-Host 'Gentleman Windows: read-only diagnostics' -ForegroundColor Cyan
foreach ($item in $tools) {
  $found = Get-Command $item.Command -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $found) {
    Write-Host ('[MISSING] ' + $item.Name) -ForegroundColor Yellow
    continue
  }
  try {
    $output = & $found.Source @($item.Args) 2>&1
    $status = $LASTEXITCODE
    $firstLine = (($output | Out-String).Trim() -split "\r?\n" | Select-Object -First 1)
    $label = if ($status -eq 0) { '[OK] ' } else { '[ERROR] ' }
    $color = if ($status -eq 0) { 'Green' } else { 'Yellow' }
    Write-Host ($label + $item.Name + ': ' + $firstLine) -ForegroundColor $color
    Write-Host ('  Path: ' + $found.Source)
  } catch {
    Write-Host ('[ERROR] ' + $item.Name + ': ' + $_.Exception.Message) -ForegroundColor Yellow
  }
}
$nvimConfig = Join-Path $env:LOCALAPPDATA 'nvim\init.lua'
if (Test-Path -LiteralPath $nvimConfig -PathType Leaf) {
  Write-Host ('[OK] Neovim config: ' + $nvimConfig) -ForegroundColor Green
} else {
  Write-Host ('[MISSING] Neovim config: ' + $nvimConfig) -ForegroundColor Yellow
}
Write-Host 'No changes were made. Run :checkhealth in Neovim for plugin checks.' -ForegroundColor Cyan

Write-Host '--- Gentle Shell JS 4.9.0 / Engram diagnostics (read only) ---'
$expectedHome = Join-Path $env:USERPROFILE 'apps\GENTLE_SHELL_490\agent-home'
$expectedLauncher = Join-Path $env:USERPROFILE 'apps\bin\gentle-shell.cmd'
$gentlePkg = Join-Path $env:USERPROFILE 'apps\GENTLE_SHELL_490\node_modules\gentle-pi\package.json'
if (Test-Path -LiteralPath $gentlePkg -PathType Leaf) {
  $version = (Get-Content -LiteralPath $gentlePkg -Raw | ConvertFrom-Json).version
  Write-Host "[INFO] gentle-pi JS package version: $version"
} else {
  Write-Host '[MISSING] gentle-pi JS installation at expected path.'
}
if (Test-Path -LiteralPath $expectedLauncher -PathType Leaf) {
  Write-Host "[INFO] Launcher: $expectedLauncher"
} else {
  Write-Host '[MISSING] Isolated Gentle Shell launcher.'
}
if (Test-Path -LiteralPath (Join-Path $expectedHome 'settings.json') -PathType Leaf) {
  $settings = Get-Content -LiteralPath (Join-Path $expectedHome 'settings.json') -Raw | ConvertFrom-Json
  $packageName = 'npm:gentle-engram@0.4.2'
  if (@($settings.packages) -contains $packageName) {
    Write-Host "[OK] Engram extension registered: $packageName"
  } else {
    Write-Host '[INFO] gentle-engram@0.4.2 not registered in isolated home.'
  }
} else {
  Write-Host '[MISSING] settings.json under isolated Pi home (do not copy secrets from GitHub).'
}
$engramExe = Join-Path $env:USERPROFILE 'apps\engram\engram.exe'
if (Test-Path -LiteralPath $engramExe -PathType Leaf) {
  Write-Host "[INFO] Engram executable exists: $engramExe (execution not tested)"
} else {
  Write-Host '[MISSING] Engram local executable.'
}
try {
  $client = New-Object System.Net.Sockets.TcpClient
  try {
    $async = $client.BeginConnect('127.0.0.1', 7437, $null, $null)
    if ($async.AsyncWaitHandle.WaitOne(750)) {
      try { $client.EndConnect($async); Write-Host '[OK] Engram TCP 127.0.0.1:7437 reachable.' }
      catch { Write-Host '[WARN] Engram TCP connection failed.' }
    } else { Write-Host '[WARN] Engram TCP timeout.' }
  } finally { $client.Close() }
} catch { Write-Host '[WARN] Engram TCP probe unavailable.' }
Write-Host '[INFO] No mem_* call was made: integration verification requires manual session.'
