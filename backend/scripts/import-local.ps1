param(
    [string]$SqlFile = "$PSScriptRoot\supabase-data.sql"
)

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")

if (-not (Test-Path $SqlFile)) {
    Write-Error "SQL file not found: $SqlFile"
    exit 1
}

Push-Location $root
docker compose up -d db
Start-Sleep -Seconds 8
Get-Content $SqlFile | docker compose exec -T db psql -U baller -d baller
Write-Host "Done. Check: docker compose exec db psql -U baller -d baller -c `"SELECT COUNT(*) FROM courts;`""
Pop-Location
