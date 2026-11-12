#Requires -Version 5.1
<#
.SYNOPSIS
  Stage-aware clean commit helper that resists IDE Co-authored-by injection.
.PARAMETER MessageFile
  Path to commit message file (-F).
.PARAMETER Message
  Commit message string (written to a temp file). Prefer MessageFile for multiline.
.PARAMETER Paths
  Optional paths to git add before commit. If omitted, commits what is already staged.
#>
param(
  [string]$MessageFile = "",
  [string]$Message = "",
  [string[]]$Paths = @()
)

$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$strip = Join-Path $here "strip-ide-commit-trailers.ps1"

if ($Paths.Count -gt 0) {
  & git add -- @Paths
  if ($LASTEXITCODE -ne 0) { throw "git add failed" }
}

$tmp = $null
if (-not [string]::IsNullOrWhiteSpace($MessageFile)) {
  if (-not (Test-Path -LiteralPath $MessageFile)) { throw "MessageFile not found: $MessageFile" }
  $msgPath = $MessageFile
} elseif (-not [string]::IsNullOrWhiteSpace($Message)) {
  $tmp = Join-Path $env:TEMP ("m4trix-commit-msg-" + [guid]::NewGuid().ToString("N") + ".txt")
  $utf8 = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($tmp, $Message.TrimEnd() + "`n", $utf8)
  $msgPath = $tmp
} else {
  throw "Provide -MessageFile or -Message"
}

try {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "git"
  $psi.Arguments = "commit -F `"$msgPath`""
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.CreateNoWindow = $true
  $proc = [System.Diagnostics.Process]::Start($psi)
  $out = $proc.StandardOutput.ReadToEnd()
  $err = $proc.StandardError.ReadToEnd()
  $proc.WaitForExit()
  if ($out) { Write-Host $out.TrimEnd() }
  if ($err) { Write-Host $err.TrimEnd() }
  if ($proc.ExitCode -ne 0) { throw "git commit failed (exit $($proc.ExitCode))" }
} finally {
  if ($tmp -and (Test-Path -LiteralPath $tmp)) { Remove-Item -Force $tmp }
}

& $strip -Force
if ($LASTEXITCODE -ne 0) { throw "strip-ide-commit-trailers failed" }
Write-Host "Clean commit ready: $(git rev-parse --short HEAD)"
