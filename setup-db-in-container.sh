#!/bin/bash
# Simple script to setup database in SQL Server container
# This installs sqlcmd if needed and runs the setup script

CONTAINER_NAME="dab-sqlserver"
PASSWORD="Test123456"

echo "=== Setting up database in SQL Server container ==="

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ Error: Container $CONTAINER_NAME is not running"
    echo "Start it with: docker start $CONTAINER_NAME"
    exit 1
fi

echo "✓ Container is running"

# Copy SQL file to container
echo "📋 Copying SQL file to container..."
docker cp setup-local-db.sql "$CONTAINER_NAME:/tmp/setup.sql"

# Install sqlcmd in container (if not already installed)
echo "🔧 Installing sqlcmd tools in container..."
docker exec "$CONTAINER_NAME" bash -c "
    if [ -f /opt/mssql-tools18/bin/sqlcmd ]; then
        echo 'sqlcmd already installed'
    else
        echo 'Installing mssql-tools18...'
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg 2>/dev/null
        curl -fsSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list 2>/dev/null
        apt-get update -qq > /dev/null 2>&1
        ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mssql-tools18 unixodbc-dev > /dev/null 2>&1
        echo 'Installation complete'
    fi
"

# Execute SQL script
echo "🚀 Executing SQL script..."
docker exec "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P "$PASSWORD" \
    -C \
    -i /tmp/setup.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database setup completed successfully!"
    echo ""
    echo "Connection string:"
    echo "Server=localhost,1433;Database=DABTestDB;User Id=sa;Password=$PASSWORD;TrustServerCertificate=true"
else
    echo ""
    echo "❌ Error executing SQL script"
    exit 1
fi

