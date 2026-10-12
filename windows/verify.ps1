# Verification only: does not install, download, or alter settings.
# Windows PowerShell 5.1 compatible.
Write-Host 'Gentleman Windows environment (read-only)' -ForegroundColor Cyan
$checks = @(
  @{ Name='Git'; Command='git'; Args=@('--version') },
  @{ Name='Node'; Command='node'; Args=@('--version') },
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
foreach ($item in $checks) {
  $found = Get-Command $item.Command -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $found) {
    Write-Host ('[MISSING] ' + $item.Name) -ForegroundColor Yellow
    continue
  }
  try {
    $output = & $found.Source @($item.Args) 2>&1
    $status = $LASTEXITCODE
    $firstLine = (($output | Out-String).Trim() -split "\r?\n" | Select-Object -First 1)
    if ($status -ne 0) {
      Write-Host ('[ERROR] ' + $item.Name + ': ' + $firstLine) -ForegroundColor Yellow
    } else {
      Write-Host ('[OK] ' + $item.Name + ': ' + $firstLine) -ForegroundColor Green
    }
  } catch {
    Write-Host ('[ERROR] ' + $item.Name + ': ' + $_.Exception.Message) -ForegroundColor Yellow
  }
}
$nvimConfig = Join-Path $env:LOCALAPPDATA 'nvim\init.lua'
if (Test-Path -LiteralPath $nvimConfig) {
  Write-Host '[OK] Neovim configuration present' -ForegroundColor Green
} else {
  Write-Host '[MISSING] Neovim configuration' -ForegroundColor Yellow
}
Write-Host 'Done. Run :checkhealth within Neovim for plugin diagnostics.'
