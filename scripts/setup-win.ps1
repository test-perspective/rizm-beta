param(
  [ValidateSet("local", "domain")]
  [string]$Mode = "local",
  [string]$Domain = "",
  [string]$Email = "",
  [string]$ApiImage = "",
  [string]$WebImage = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Rizm Beta - Windows Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check winget
Write-Host "[1/5] Checking winget..." -ForegroundColor Yellow
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "ERROR: winget is not available. Please install Windows Package Manager." -ForegroundColor Red
  Write-Host "  Download: https://aka.ms/getwinget" -ForegroundColor Yellow
  exit 1
}
Write-Host "  OK: winget found" -ForegroundColor Green

# Check/Install Docker Desktop
Write-Host ""
Write-Host "[2/5] Checking Docker Desktop..." -ForegroundColor Yellow
$dockerInstalled = $false
if (Get-Command docker -ErrorAction SilentlyContinue) {
  try {
    $null = docker version 2>&1
    $dockerInstalled = $true
    Write-Host "  OK: Docker is installed and running" -ForegroundColor Green
  } catch {
    Write-Host "  Docker command found but not responding. Starting Docker Desktop..." -ForegroundColor Yellow
  }
}

if (-not $dockerInstalled) {
  Write-Host "  Installing Docker Desktop via winget..." -ForegroundColor Yellow
  winget install --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install Docker Desktop" -ForegroundColor Red
    exit 1
  }
  Write-Host "  Docker Desktop installed. Please start it manually and run this script again." -ForegroundColor Yellow
  Write-Host "  Or wait a moment and Docker Desktop should start automatically..." -ForegroundColor Yellow
}

# Wait for Docker to be ready
Write-Host ""
Write-Host "[3/5] Waiting for Docker to be ready..." -ForegroundColor Yellow
$maxWait = 60
$waited = 0
while ($waited -lt $maxWait) {
  try {
    $null = docker version 2>&1
    Write-Host "  OK: Docker is ready" -ForegroundColor Green
    break
  } catch {
    Start-Sleep -Seconds 2
    $waited += 2
    Write-Host "  Waiting... ($waited/$maxWait seconds)" -ForegroundColor DarkGray
  }
}

if ($waited -ge $maxWait) {
  Write-Host "ERROR: Docker did not become ready within $maxWait seconds" -ForegroundColor Red
  Write-Host "  Please start Docker Desktop manually and run this script again." -ForegroundColor Yellow
  exit 1
}

# Prepare .env
Write-Host ""
Write-Host "[4/5] Preparing .env file..." -ForegroundColor Yellow
$envPath = Join-Path $repoRoot ".env"
$envExamplePath = Join-Path $repoRoot ".env.example"

if (-not (Test-Path $envPath)) {
  if (Test-Path $envExamplePath) {
    Copy-Item $envExamplePath $envPath
    Write-Host "  Created .env from .env.example" -ForegroundColor Green
  } else {
    Write-Host "  WARNING: .env.example not found. Creating minimal .env..." -ForegroundColor Yellow
    @"
RIZM_API_IMAGE=kabekenputer/keel-api:latest
RIZM_WEB_IMAGE=kabekenputer/keel-web:latest
KEEL_BOOTSTRAP_ADMIN_EMAIL=admin@example.local
KEEL_BOOTSTRAP_ADMIN_PASSWORD=change-this-password
KEEL_COOKIE_SECURE=false
"@ | Out-File -FilePath $envPath -Encoding utf8
  }
} else {
  Write-Host "  .env already exists, skipping" -ForegroundColor DarkGray
}

# Override image settings if provided
if ($ApiImage) {
  (Get-Content $envPath) -replace '^RIZM_API_IMAGE=.*', "RIZM_API_IMAGE=$ApiImage" | Set-Content $envPath
}
if ($WebImage) {
  (Get-Content $envPath) -replace '^RIZM_WEB_IMAGE=.*', "RIZM_WEB_IMAGE=$WebImage" | Set-Content $envPath
}

# Domain mode: set domain and email
if ($Mode -eq "domain") {
  if (-not $Domain) {
    Write-Host "ERROR: --domain is required for domain mode" -ForegroundColor Red
    exit 1
  }
  if (-not $Email) {
    Write-Host "ERROR: --email is required for domain mode" -ForegroundColor Red
    exit 1
  }
  
  $envContent = Get-Content $envPath -Raw
  $envContent = $envContent -replace '^APP_DOMAIN=.*', "APP_DOMAIN=$Domain"
  $envContent = $envContent -replace '^LETSENCRYPT_EMAIL=.*', "LETSENCRYPT_EMAIL=$Email"
  $envContent = $envContent -replace '^KEEL_COOKIE_SECURE=.*', "KEEL_COOKIE_SECURE=true"
  if ($envContent -notmatch 'APP_DOMAIN=') {
    $envContent += "`nAPP_DOMAIN=$Domain`n"
  }
  if ($envContent -notmatch 'LETSENCRYPT_EMAIL=') {
    $envContent += "`nLETSENCRYPT_EMAIL=$Email`n"
  }
  $envContent | Set-Content $envPath -Encoding utf8
  Write-Host "  Configured for domain mode: $Domain" -ForegroundColor Green
}

# Start Docker Compose
Write-Host ""
Write-Host "[5/5] Starting Rizm with Docker Compose..." -ForegroundColor Yellow

$composeFile = if ($Mode -eq "domain") {
  "compose\docker-compose.domain.yml"
} else {
  "compose\docker-compose.local.yml"
}

Push-Location $repoRoot
try {
  $envFile = Join-Path $repoRoot ".env"

  docker compose --env-file $envFile -f $composeFile pull
  if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: docker compose pull failed, continuing anyway..." -ForegroundColor Yellow
  }
  
  docker compose --env-file $envFile -f $composeFile up -d
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to start containers" -ForegroundColor Red
    exit 1
  }
  
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "Rizm is starting!" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host ""
  
  if ($Mode -eq "local") {
    Write-Host "Access Rizm at: http://localhost:8080" -ForegroundColor Cyan
  } else {
    Write-Host "Access Rizm at: https://$Domain" -ForegroundColor Cyan
    Write-Host "  (SSL certificate may take a few minutes to be issued)" -ForegroundColor DarkGray
  }
  
  Write-Host ""
  Write-Host "Default admin credentials:" -ForegroundColor Yellow
  Write-Host "  Email: admin@example.local" -ForegroundColor White
  Write-Host "  Password: change-this-password" -ForegroundColor White
  Write-Host ""
  Write-Host "To check status: docker compose --env-file $envFile -f $composeFile ps" -ForegroundColor DarkGray
  Write-Host "To view logs: docker compose --env-file $envFile -f $composeFile logs -f" -ForegroundColor DarkGray
  Write-Host "To stop: docker compose --env-file $envFile -f $composeFile down" -ForegroundColor DarkGray
  
} finally {
  Pop-Location
}
