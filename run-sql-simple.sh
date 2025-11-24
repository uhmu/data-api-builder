#!/bin/bash
# Simple script to run SQL in container using direct SQL execution

CONTAINER_NAME="dab-sqlserver"
PASSWORD="Test123456"

# Method: Install sqlcmd in container and use it
echo "Installing sqlcmd in container..."
docker exec "$CONTAINER_NAME" bash -c "
    # Check if sqlcmd already exists
    if command -v sqlcmd &> /dev/null || [ -f /opt/mssql-tools18/bin/sqlcmd ]; then
        echo 'sqlcmd already available'
    else
        # Install sqlcmd
        curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 2>/dev/null
        curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list 2>/dev/null
        apt-get update -qq
        ACCEPT_EULA=Y apt-get install -y -qq mssql-tools18 unixodbc-dev 2>/dev/null
    fi
"

# Copy SQL file
echo "Copying SQL file to container..."
docker cp setup-local-db.sql "$CONTAINER_NAME:/tmp/setup.sql"

# Execute SQL
echo "Executing SQL script..."
docker exec "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -P "$PASSWORD" \
    -C \
    -i /tmp/setup.sql

echo "Done!"

