# PowerShell script to execute SQL in SQL Server container
# Alternative method: Execute SQL directly without sqlcmd in container

$containerName = "dab-sqlserver"
$sqlFile = "setup-local-db.sql"
$password = "Test123456"

# Check if container is running
$containerRunning = docker ps --filter "name=$containerName" --format "{{.Names}}"
if (-not $containerRunning) {
    Write-Host "Error: Container $containerName is not running" -ForegroundColor Red
    exit 1
}

Write-Host "Copying SQL file to container..." -ForegroundColor Green
docker cp $sqlFile "${containerName}:/tmp/setup.sql"

Write-Host "Installing sqlcmd in container (if needed)..." -ForegroundColor Green
docker exec $containerName bash -c @"
    if [ ! -f /opt/mssql-tools18/bin/sqlcmd ]; then
        curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 2>/dev/null
        curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list 2>/dev/null
        apt-get update -qq
        ACCEPT_EULA=Y apt-get install -y -qq mssql-tools18 unixodbc-dev 2>/dev/null
    fi
"@

Write-Host "Executing SQL script..." -ForegroundColor Green
docker exec $containerName /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $password `
    -C `
    -i /tmp/setup.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "SQL script executed successfully!" -ForegroundColor Green
} else {
    Write-Host "Error executing SQL script" -ForegroundColor Red
}

