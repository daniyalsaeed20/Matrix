#Requires -Version 5.1
<#
.SYNOPSIS
  Rewrite HEAD commit message to remove IDE/AI-editor attribution trailers.
.DESCRIPTION
  Some IDE agent shells inject `Co-authored-by: Cursor <cursoragent@cursor.com>`
  into `git commit` (sometimes inline on the subject line, sometimes after hooks).
  This helper rebuilds HEAD via `git commit-tree` so the injector is bypassed.
  Does not change git config. Refuses to run if the working tree is not clean
  relative to HEAD (staged/unstaged changes) unless -Force.
#>
param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"

function Get-CleanCommitMessage([string]$msg) {
  $patterns = @(
    '(?i)[ \t]*Co-authored-by:\s*Cursor\s*<cursoragent@cursor\.com>[ \t]*',
    '(?i)[ \t]*Made-with:\s*Cursor[ \t]*',
    '(?i)[ \t]*Made with Cursor[ \t]*',
    '(?i)[ \t]*Generated with Cursor[ \t]*',
    '(?i)[ \t]*Generated-by:\s*Cursor[ \t]*'
  )
  # Strip UTF-8 BOM if present (PowerShell Set-Content -Encoding UTF8 often adds it).
  $clean = $msg -replace '^\uFEFF', ''
  foreach ($p in $patterns) {
    $clean = [regex]::Replace($clean, $p, "")
  }
  $clean = [regex]::Replace($clean, "(\r?\n){3,}", "`n`n")
  $clean = [regex]::Replace($clean, "[ \t]+\r?\n", "`n")
  return $clean.Trim() + "`n"
}

$status = git status --porcelain
if ($status -and -not $Force) {
  throw "Working tree not clean. Commit/stash first, or pass -Force."
}

$msg = git log -1 --format=%B
$clean = Get-CleanCommitMessage $msg
if ($clean -eq ($msg.Trim() + "`n") -or $clean.Trim() -eq $msg.Trim()) {
  # Still compare without trailer presence
  if ($msg -notmatch "(?i)Co-authored-by:\s*Cursor|cursoragent@cursor\.com|(?i)Made with Cursor|(?i)Made-with:\s*Cursor|(?i)Generated with Cursor") {
    Write-Host "HEAD already clean"
    exit 0
  }
}

$tree = git rev-parse "HEAD^{tree}"
$parents = @(git rev-parse "HEAD^@" 2>$null | Where-Object { $_ })
$env:GIT_AUTHOR_NAME = git log -1 --format=%an
$env:GIT_AUTHOR_EMAIL = git log -1 --format=%ae
$env:GIT_AUTHOR_DATE = git log -1 --format=%aI
$env:GIT_COMMITTER_NAME = git log -1 --format=%cn
$env:GIT_COMMITTER_EMAIL = git log -1 --format=%ce
$env:GIT_COMMITTER_DATE = git log -1 --format=%cI

$argList = New-Object System.Collections.Generic.List[string]
$argList.Add("commit-tree") | Out-Null
$argList.Add($tree) | Out-Null
foreach ($p in $parents) {
  $argList.Add("-p") | Out-Null
  $argList.Add($p) | Out-Null
}

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "git"
# Windows PowerShell 5.1: use Arguments string (ArgumentList is .NET Core / pwsh).
$psi.Arguments = (($argList | ForEach-Object {
  if ($_ -match '[\s"]') { '"{0}"' -f ($_ -replace '"', '\"') } else { $_ }
}) -join " ")
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.CreateNoWindow = $true

$proc = [System.Diagnostics.Process]::Start($psi)
# Avoid StreamWriter UTF-8 BOM on stdin.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$msgBytes = $utf8NoBom.GetBytes([string]$clean)
$proc.StandardInput.BaseStream.Write($msgBytes, 0, $msgBytes.Length)
$proc.StandardInput.BaseStream.Flush()
$proc.StandardInput.Close()
$new = $proc.StandardOutput.ReadToEnd().Trim()
$err = $proc.StandardError.ReadToEnd()
$proc.WaitForExit()
if ($proc.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($new)) {
  throw "commit-tree failed (exit $($proc.ExitCode)): $err"
}

& git update-ref HEAD $new
Write-Host "Rewrote HEAD -> $new"
$final = git log -1 --format=%B
Write-Host "---- message ----"
Write-Host $final
Write-Host "---- end ----"
if ($final -match "(?i)cursoragent@cursor|(?i)Co-authored-by:\s*Cursor|(?i)Made with Cursor") {
  throw "Trailer still present after rewrite"
}
Write-Host "TRAILER_CLEAN"
