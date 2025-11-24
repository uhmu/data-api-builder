#!/bin/bash
# Script to execute SQL in SQL Server container without sqlcmd

CONTAINER_NAME="dab-sqlserver"
SQL_FILE="setup-local-db.sql"
PASSWORD="Test123456"

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: Container $CONTAINER_NAME is not running"
    exit 1
fi

# Copy SQL file into container
echo "Copying SQL file into container..."
docker cp "$SQL_FILE" "$CONTAINER_NAME:/tmp/setup.sql"

# Execute SQL using a different method
# Method 1: Try using /opt/mssql-tools18/bin/sqlcmd (newer path)
if docker exec "$CONTAINER_NAME" test -f /opt/mssql-tools18/bin/sqlcmd; then
    echo "Using /opt/mssql-tools18/bin/sqlcmd..."
    docker exec "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd \
        -S localhost -U sa -P "$PASSWORD" \
        -i /tmp/setup.sql
# Method 2: Try using sqlcmd from PATH
elif docker exec "$CONTAINER_NAME" which sqlcmd > /dev/null 2>&1; then
    echo "Using sqlcmd from PATH..."
    docker exec "$CONTAINER_NAME" sqlcmd \
        -S localhost -U sa -P "$PASSWORD" \
        -i /tmp/setup.sql
# Method 3: Use Python to execute SQL (if available)
elif docker exec "$CONTAINER_NAME" python3 --version > /dev/null 2>&1; then
    echo "Using Python to execute SQL..."
    docker exec "$CONTAINER_NAME" python3 -c "
import pyodbc
conn = pyodbc.connect('DRIVER={ODBC Driver 18 for SQL Server};SERVER=localhost;UID=sa;PWD=$PASSWORD;TrustServerCertificate=yes')
cursor = conn.cursor()
with open('/tmp/setup.sql', 'r') as f:
    sql = f.read()
    for statement in sql.split('GO'):
        if statement.strip():
            cursor.execute(statement)
conn.commit()
conn.close()
"
else
    echo "Error: No method found to execute SQL in container"
    echo "Trying alternative: Execute SQL statements directly..."
    
    # Read SQL file and execute statements one by one
    docker exec -i "$CONTAINER_NAME" bash -c "
        # Install sqlcmd if possible
        if ! command -v sqlcmd &> /dev/null; then
            curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
            curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
            apt-get update
            ACCEPT_EULA=Y apt-get install -y mssql-tools18
            echo 'export PATH=\"\$PATH:/opt/mssql-tools18/bin\"' >> ~/.bashrc
        fi
        
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$PASSWORD' -i /tmp/setup.sql
    "
fi

echo "SQL script execution completed!"

