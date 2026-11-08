
$ErrorActionPreference = "Stop"

Write-Host "======================================"
Write-Host " OpenClaw Gemini Docker Installer"
Write-Host "======================================"

if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not installed."
}

docker compose version
if ($LASTEXITCODE -ne 0) {
    throw "Docker Compose v2 is required."
}

if (!(Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Configure .env before installation."
    exit 1
}

$envContent = Get-Content ".env"

foreach ($line in $envContent) {
    if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
        [Environment]::SetEnvironmentVariable(
            $Matches[1],
            $Matches[2],
            "Process"
        )
    }
}

if (!$env:GEMINI_API_KEY -or
    $env:GEMINI_API_KEY -eq "YOUR_GEMINI_API_KEY") {
    throw "GEMINI_API_KEY is missing."
}

if (!$env:OPENCLAW_GATEWAY_TOKEN -or
    $env:OPENCLAW_GATEWAY_TOKEN -eq "CHANGE_ME") {
    throw "OPENCLAW_GATEWAY_TOKEN is missing."
}

Write-Host "[1/5] Validating Compose..."
docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw "Compose validation failed." }

Write-Host "[2/5] Pulling image..."
docker compose pull
if ($LASTEXITCODE -ne 0) { throw "Image pull failed." }

Write-Host "[3/5] Creating volume..."
docker volume create openclaw-state
if ($LASTEXITCODE -ne 0) { throw "Volume creation failed." }

Write-Host "[4/5] Initializing configuration..."

$init = @'
mkdir -p /data/workspace /data/logs/support
if [ ! -f /data/openclaw.json ]; then
cat > /data/openclaw.json <<'EOF'
{
  "gateway": {
    "mode": "local"
  },
  "http": {
    "endpoints": {
      "chatCompletions": {
        "enabled": true
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-3.1-flash-lite"
      }
    }
  }
}
EOF
fi
chown -R 1000:1000 /data
'@

docker run --rm -v openclaw-state:/data alpine:3.20 sh -c $init
if ($LASTEXITCODE -ne 0) { throw "Initialization failed." }

Write-Host "[5/5] Starting Gateway..."
docker compose up -d openclaw-gateway
if ($LASTEXITCODE -ne 0) { throw "Gateway startup failed." }

Write-Host "Installation completed!"
Write-Host "Dashboard: http://127.0.0.1:18789"
