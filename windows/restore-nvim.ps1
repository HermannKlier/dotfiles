#requires -Version 5.1
<#
.PURPOSE
  Prepare/test the documented GentlemanNvim Windows-only fixes.
  Default: preview only. -Apply: explicit patch with backup.
  Does not install plugins or modify macOS dotfiles.
#>
[CmdletBinding()]
param(
  [switch]$Apply,
  [string]$ConfigRoot = (Join-Path $env:LOCALAPPDATA 'nvim')
)
$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath($ConfigRoot)
Write-Host ('Configuration target: ' + $root)
$paths = @{
  node = Join-Path $root 'lua\config\nodejs.lua'
  lazy = Join-Path $root 'lua\config\lazy.lua'
  gemini = Join-Path $root 'lua\plugins\gemini.lua'
}
foreach ($key in @('node','lazy','gemini')) {
  if (-not (Test-Path -LiteralPath $paths[$key] -PathType Leaf)) {
    throw "Required file not found: $($paths[$key]). Install an approved GentlemanNvim base first. Nothing changed."
  }
}
$utf8 = New-Object System.Text.UTF8Encoding($false)
$source = @{}
$updated = @{}
foreach ($key in @('node','lazy','gemini')) {
  $source[$key] = [System.IO.File]::ReadAllText($paths[$key])
  $updated[$key] = $source[$key]
}
function Replace-Checked {
  param([string]$InputText,[string]$Old,[string]$New,[string]$Label)
  if ($InputText.Contains($Old)) {
    return $InputText.Replace($Old,$New)
  }
  if ($InputText.Contains($New)) { return $InputText }
  throw "Unexpected version of ${Label}: required marker absent. Nothing changed."
}
# Node version tests: use argument lists, not a shell command string.
$updated.node = Replace-Checked $updated.node 'vim.fn.system(node_path .. " --version 2>/dev/null")' 'vim.fn.system({ node_path, "--version" })' 'nodejs.lua/version setup'
$updated.node = Replace-Checked $updated.node 'vim.fn.system(vim.g.node_host_prog .. " --version 2>/dev/null")' 'vim.fn.system({ vim.g.gentle_node_path, "--version" })' 'nodejs.lua/version helpers'
$updated.node = $updated.node.Replace('vim.g.node_host_prog', 'vim.g.gentle_node_path')
if (-not $updated.node.Contains('vim.g.gentle_node_path')) {
  throw 'nodejs.lua unexpected content. Nothing changed.'
}
# Do not mistake node.exe for neovim-node-host.
$oldHost = 'vim.g.node_host_prog = vim.fn.exepath("node") or "/usr/local/bin/node"'
$newHost = '-- Node.js detection is handled by config.nodejs'
$updated.lazy = Replace-Checked $updated.lazy $oldHost $newHost 'lazy.lua/node host'
# Add optional LuaRocks disable only when missing. Refuse unknown lazy structure.
if ($updated.lazy -notmatch 'rocks\s*=\s*\{\s*enabled\s*=\s*false') {
  $marker = 'install = { colorscheme = { "tokyonight", "habamax" } },'
  if (-not $updated.lazy.Contains($marker)) { throw 'lazy.lua install marker not found. Nothing changed.' }
  $updated.lazy = $updated.lazy.Replace($marker, "rocks = { enabled = false },`r`n  " + $marker)
}
# Disable gemini plugin on Windows while preserving other existing settings.
$geminiMarker = '"jonroosevelt/gemini-cli.nvim",'
$enableLine = 'enabled = vim.fn.has("win32") == 0,'
if (-not $updated.gemini.Contains($geminiMarker)) { throw 'Unexpected gemini.lua content. Nothing changed.' }
if (-not $updated.gemini.Contains($enableLine)) {
  if ($updated.gemini -match '(?m)^\s*enabled\s*=') { throw 'gemini.lua has another enabled setting; review manually. Nothing changed.' }
  $updated.gemini = $updated.gemini.Replace($geminiMarker, $geminiMarker + "`r`n  " + $enableLine)
}
# Reject obsolete node_host_prog assignments in the edited config.
if ($updated.node.Contains('vim.g.node_host_prog') -or $updated.lazy.Contains('vim.g.node_host_prog')) {
  throw 'Obsolete node_host_prog reference remains. Nothing changed.'
}
$changes = @('node','lazy','gemini') | Where-Object { $updated[$_] -cne $source[$_] }
foreach ($key in @('node','lazy','gemini')) {
  $status = if ($changes -contains $key) { 'PATCH' } else { 'UNCHANGED' }
  Write-Host ("[$status] " + $paths[$key])
}
if (-not $Apply) {
  Write-Host 'PREVIEW ONLY: no files were modified. Use -Apply only after review.' -ForegroundColor Yellow
  return
}
if ($changes.Count -eq 0) {
  Write-Host 'Already compliant. No files changed and no backup needed.' -ForegroundColor Green
  return
}
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path (Split-Path $root -Parent) ("nvim-backup-restore-$stamp")
if (Test-Path -LiteralPath $backup) { throw "Backup already exists: $backup" }
Copy-Item -LiteralPath $root -Destination $backup -Recurse -ErrorAction Stop
Write-Host "Backup created: $backup" -ForegroundColor Green
foreach ($key in $changes) {
  [System.IO.File]::WriteAllText($paths[$key], $updated[$key], $utf8)
  Write-Host ("[UPDATED] " + $paths[$key]) -ForegroundColor Green
}
Write-Host 'Done. Review changes and test with nvim --headless. No plugins were installed.' -ForegroundColor Cyan
