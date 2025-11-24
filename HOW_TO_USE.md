# How to Use Data API Builder

## Quick Start

### 1. Run the CLI Tool

After building the project, the CLI tool is located at:
```
src/out/cli/net8.0/Microsoft.DataApiBuilder.dll
```

Run it using:
```powershell
cd src
dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll --help
```

### 2. Initialize Configuration

Create your initial configuration file:

```powershell
dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll init `
  --database-type mssql `
  --connection-string "your-connection-string" `
  --host-mode development
```

**Supported database types:**
- `mssql` - SQL Server / Azure SQL
- `postgresql` - PostgreSQL
- `mysql` - MySQL
- `cosmosdb_nosql` - Cosmos DB

### 3. Add Entities

Add tables, views, or stored procedures to your API:

```powershell
dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll add Todo `
  --source "dbo.Todo" `
  --permissions "anonymous:*"
```

### 4. Start the Service

Run the Data API Builder service:

```powershell
dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll start
```

The service will look for `dab-config.json` in the current directory.

### 5. Access Your API

Once started, access your endpoints:

- **REST API**: `http://localhost:5000/api/{entity}`
- **GraphQL**: `http://localhost:5000/graphql`
- **Swagger UI**: `http://localhost:5000/swagger` (development mode)
- **Health Check**: `http://localhost:5000/health`

## Available Commands

- `init` - Initialize a new configuration file
- `add` - Add entities (tables/views) to your API
- `update` - Update entity configurations
- `start` - Start the Data API Builder service
- `validate` - Validate your configuration file
- `export` - Export GraphQL schema
- `add-telemetry` - Configure telemetry
- `configure` - Configure runtime settings

## Using Environment Variables

Create a `.env` file for connection strings:

```powershell
# PowerShell
echo "my-connection-string=Server=localhost;Database=mydb;..." > .env
```

Then reference it in your config:
```json
{
  "data-source": {
    "connection-string": "@env('my-connection-string')"
  }
}
```

## Alternative: Install as Global Tool

Package and install as a global tool:

```powershell
cd src/Cli
dotnet pack
dotnet tool install -g --add-source ./bin/Debug Microsoft.DataApiBuilder
```

Then use the `dab` command directly:
```powershell
dab --help
dab init --database-type mssql --connection-string "..." --host-mode development
dab start
```

## Example Workflow

1. **Initialize**: `dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll init --database-type mssql --connection-string "..." --host-mode development`
2. **Add Entity**: `dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll add Todo --source "dbo.Todo" --permissions "anonymous:*"`
3. **Start**: `dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll start`
4. **Test**: Open `http://localhost:5000/api/Todo` in your browser

## Configuration File

The configuration file (`dab-config.json`) is created automatically and contains:
- Database connection settings
- REST and GraphQL endpoint configuration
- Entity definitions and permissions
- Authentication settings

For more details, see the [official documentation](https://learn.microsoft.com/azure/data-api-builder/).

