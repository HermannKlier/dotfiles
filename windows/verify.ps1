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
