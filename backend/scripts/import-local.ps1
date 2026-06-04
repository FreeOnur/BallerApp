# Import Supabase export into local Docker Postgres
# Usage: .\import-local.ps1 -SqlFile .\supabase-data.sql

param(
    [string]$SqlFile = "$PSScriptRoot\supabase-data.sql",
    [string]$ComposeFile = "$PSScriptRoot\..\docker-compose.dev.yml"
)

if (-not (Test-Path $SqlFile)) {
    Write-Error "SQL file not found: $SqlFile. Run export-from-supabase.md steps first."
    exit 1
}

$composeDir = Split-Path $ComposeFile -Parent
Push-Location $composeDir

docker compose -f docker-compose.dev.yml up -d db
Start-Sleep -Seconds 5

Get-Content $SqlFile | docker compose -f docker-compose.dev.yml exec -T db `
    psql -U baller -d baller

Write-Host "Import finished. Validate with:"
Write-Host "  docker compose -f docker-compose.dev.yml exec db psql -U baller -d baller -c `"SELECT COUNT(*) FROM courts;`""

Pop-Location
