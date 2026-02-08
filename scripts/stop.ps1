# Stops the portable Tomcat started by scripts/run.ps1

$ErrorActionPreference = "Stop"

function Write-Info([string]$msg) { Write-Host "[stop] $msg" }

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$RuntimeDir = Join-Path $ProjectRoot ".runtime"
$TomcatVersion = "9.0.115"
$TomcatHome = Join-Path $RuntimeDir ("apache-tomcat-" + $TomcatVersion)
$TomcatBin = Join-Path $TomcatHome "bin"

if (!(Test-Path $TomcatBin)) {
  Write-Info "Tomcat not found at $TomcatHome"
  exit 0
}

# Try to reuse JAVA_HOME detection
function Get-JavaHome {
  if ($env:JAVA_HOME -and (Test-Path $env:JAVA_HOME)) { return $env:JAVA_HOME }
  try {
    $javaSettingsText = (& java -XshowSettings:properties -version 2>&1) -join "`n"
    $m = [regex]::Match($javaSettingsText, "^\s*java\.home\s*=\s*(.+)\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($m.Success) {
      $p = $m.Groups[1].Value.Trim()
      if ($p -and (Test-Path $p)) { return $p }
    }
  } catch { }
  try {
    $jdkDir = Get-ChildItem "C:\Program Files\Java" -Directory -Filter "jdk-*" -ErrorAction SilentlyContinue |
      Sort-Object Name -Descending |
      Select-Object -First 1
    if ($jdkDir -and (Test-Path $jdkDir.FullName)) { return $jdkDir.FullName }
  } catch { }
  return $null
}

$javaHome = Get-JavaHome

Write-Info "Stopping Tomcat..."
$ShutdownCmd = "set JAVA_HOME=$javaHome&& set JRE_HOME=$javaHome&& cd /d `"$TomcatBin`"&& shutdown.bat"
cmd /c $ShutdownCmd | Out-Null

