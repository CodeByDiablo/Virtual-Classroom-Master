# Runs the Virtual-Classroom JSP app on a portable Tomcat.
# No global installs required (except Java which you already have).

$ErrorActionPreference = "Stop"

function Write-Info([string]$msg) { Write-Host "[run] $msg" }

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$AppName = Split-Path $ProjectRoot -Leaf

$RuntimeDir = Join-Path $ProjectRoot ".runtime"
$TomcatVersion = "9.0.115"
$TomcatBaseName = "apache-tomcat-$TomcatVersion"
$TomcatZipUrl = "https://dlcdn.apache.org/tomcat/tomcat-9/v$TomcatVersion/bin/$TomcatBaseName.zip"
$TomcatZipPath = Join-Path $RuntimeDir "$TomcatBaseName.zip"
$TomcatHome = Join-Path $RuntimeDir $TomcatBaseName

$MysqlJarVersion = "9.6.0"
$MysqlJarName = "mysql-connector-j-$MysqlJarVersion.jar"
$MysqlJarUrl = "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/$MysqlJarVersion/$MysqlJarName"
$MysqlJarDest = Join-Path $TomcatHome ("lib\" + $MysqlJarName)

New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null

Write-Info "Project: $ProjectRoot"
Write-Info "AppName:  $AppName"

# Ensure Tomcat can find Java (Tomcat's batch scripts require JAVA_HOME or JRE_HOME)
function Get-JavaHome {
  # 1) Respect existing JAVA_HOME if valid
  if ($env:JAVA_HOME -and (Test-Path $env:JAVA_HOME)) { return $env:JAVA_HOME }

  # 2) Try parsing from the running java
  try {
    $javaSettingsText = (& java -XshowSettings:properties -version 2>&1) -join "`n"
    $m = [regex]::Match($javaSettingsText, "^\s*java\.home\s*=\s*(.+)\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($m.Success) {
      $p = $m.Groups[1].Value.Trim()
      if ($p -and (Test-Path $p)) { return $p }
    }
  } catch { }

  # 3) Common install location fallback
  try {
    $jdkDir = Get-ChildItem "C:\Program Files\Java" -Directory -Filter "jdk-*" -ErrorAction SilentlyContinue |
      Sort-Object Name -Descending |
      Select-Object -First 1
    if ($jdkDir -and (Test-Path $jdkDir.FullName)) { return $jdkDir.FullName }
  } catch { }

  return $null
}

$javaHome = Get-JavaHome
if ($javaHome) {
  $env:JAVA_HOME = $javaHome
  $env:JRE_HOME = $javaHome
  Write-Info "JAVA_HOME set to: $javaHome"
} else {
  Write-Info "JAVA_HOME not detected; Tomcat will likely fail to start."
}

if (!(Test-Path $TomcatHome)) {
  if (!(Test-Path $TomcatZipPath)) {
    Write-Info "Downloading Tomcat $TomcatVersion..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $TomcatZipUrl -OutFile $TomcatZipPath
  }

  Write-Info "Extracting Tomcat..."
  Expand-Archive -Path $TomcatZipPath -DestinationPath $RuntimeDir -Force
}

if (!(Test-Path $MysqlJarDest)) {
  Write-Info "Downloading MySQL JDBC driver ($MysqlJarVersion)..."
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $MysqlJarUrl -OutFile $MysqlJarDest
}

# Best-effort stop if already running
$ShutdownBat = Join-Path $TomcatHome "bin\\shutdown.bat"
if (Test-Path $ShutdownBat) {
  try { & $ShutdownBat | Out-Null } catch { }
}

# Deploy app folder into Tomcat webapps
$WebappsDir = Join-Path $TomcatHome "webapps"
$DeployDir = Join-Path $WebappsDir $AppName

if (Test-Path $DeployDir) {
  Write-Info "Removing previous deployment..."
  try { Remove-Item -Recurse -Force $DeployDir } catch { }
}

Write-Info "Deploying project to Tomcat webapps..."
New-Item -ItemType Directory -Force -Path $DeployDir | Out-Null

# Use robocopy for fast recursive copy
$excludeDirs = @(".runtime", "scripts", ".git", ".cursor", ".vscode")
$xd = @()
foreach ($d in $excludeDirs) { $xd += @("/XD", (Join-Path $ProjectRoot $d)) }

$rc = & robocopy $ProjectRoot $DeployDir /E /NFL /NDL /NJH /NJS /NP @xd
# Robocopy exit codes 0-7 are success.
if ($LASTEXITCODE -gt 7) {
  throw "robocopy failed with exit code $LASTEXITCODE"
}

# Start Tomcat
Write-Info "Starting Tomcat..."
$TomcatBin = Join-Path $TomcatHome "bin"
$env:JAVA_HOME = $javaHome
$env:JRE_HOME = $javaHome

# Use catalina.bat run for reliability (startup.bat uses a detached 'start' which can be flaky in non-interactive shells)
$CatalinaBat = Join-Path $TomcatBin "catalina.bat"
Start-Process -FilePath $CatalinaBat -ArgumentList "run" -WorkingDirectory $TomcatBin | Out-Null

# Wait for Tomcat to listen on 8080
Write-Info "Waiting for http://localhost:8080 ..."
$deadline = (Get-Date).AddSeconds(60)
do {
  try {
    $null = Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 "http://localhost:8080/" | Out-Null
    break
  } catch {
    Start-Sleep -Milliseconds 500
  }
} while ((Get-Date) -lt $deadline)

try {
  $null = Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 "http://localhost:8080/" | Out-Null
} catch {
  throw "Tomcat did not start on http://localhost:8080 within 60 seconds. Check logs under $TomcatHome\\logs."
}

$Url = "http://localhost:8080/$AppName/index.jsp"
Write-Info "Opening $Url"
Start-Process $Url | Out-Null

# Warn about DB if MySQL isn't running
$mysqlListening = Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -eq $mysqlListening) {
  Write-Info "NOTE: MySQL is not running on port 3306 yet. Login/Register pages will fail until you install/start MySQL and import project_DB.sql."
}

