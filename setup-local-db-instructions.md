# Setting Up Local Database with TinyInt Field

## Prerequisites

You need SQL Server installed locally. Options:
- **SQL Server Express** (free): https://www.microsoft.com/sql-server/sql-server-downloads
- **SQL Server LocalDB** (lightweight): Usually comes with Visual Studio
- **Docker** (SQL Server in container): See Docker option below

## Option 1: Using SQL Server Management Studio (SSMS) or Azure Data Studio

1. Open **SQL Server Management Studio** or **Azure Data Studio**
2. Connect to your local SQL Server instance:
   - Server name: `localhost` or `(localdb)\MSSQLLocalDB` (for LocalDB)
   - Authentication: Windows Authentication
3. Open the script file: `setup-local-db.sql`
4. Execute the script (F5 or Execute button)
5. Verify the database was created:
   ```sql
   USE DABTestDB;
   SELECT * FROM dbo.Products;
   ```

## Option 2: Using Command Line (sqlcmd)

```powershell
# For SQL Server Express/Full
sqlcmd -S localhost -E -i setup-local-db.sql

# For LocalDB
sqlcmd -S "(localdb)\MSSQLLocalDB" -i setup-local-db.sql
```

## Option 3: Using Docker (SQL Server Container)

1. **Start SQL Server container:**
   ```powershell
   docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" `
     -p 1433:1433 --name dab-sqlserver `
     -d mcr.microsoft.com/mssql/server:2022-latest
   ```

2. **Wait for container to start** (about 30 seconds)

3. **Run the setup script:**
   ```powershell
   sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -i setup-local-db.sql
   ```

## Connection String Examples

After setup, use these connection strings with Data API Builder:

**For LocalDB:**
```
Server=(localdb)\MSSQLLocalDB;Database=DABTestDB;Integrated Security=true;TrustServerCertificate=true
```

**For SQL Server Express/Full:**
```
Server=localhost;Database=DABTestDB;Integrated Security=true;TrustServerCertificate=true
```

**For Docker SQL Server:**
```
Server=localhost,1433;Database=DABTestDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=true
```

## Table Structure

The `Products` table includes:
- **StockLevel** (TINYINT): Inventory count (0-255)
- **IsActive** (TINYINT): Active status (0 or 1)
- **CategoryId** (TINYINT): Category identifier (0-255)

## Next Steps

1. **Initialize DAB configuration:**
   ```powershell
   cd src
   dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll init `
     --database-type mssql `
     --connection-string "Server=localhost;Database=DABTestDB;Integrated Security=true;TrustServerCertificate=true" `
     --host-mode development
   ```

2. **Add the Products table:**
   ```powershell
   dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll add Products `
     --source "dbo.Products" `
     --permissions "anonymous:*"
   ```

3. **Start DAB:**
   ```powershell
   dotnet out/cli/net8.0/Microsoft.DataApiBuilder.dll start
   ```

4. **Test the API:**
   - REST: `http://localhost:5000/api/Products`
   - GraphQL: `http://localhost:5000/graphql`

