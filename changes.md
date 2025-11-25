# Change Log

This document summarizes the functional additions applied on top of the fresh
`data-api-builder` checkout.

## 1. SByte Support

- Added `EdmPrimitiveTypeKind.SByte` handling across OData parsing, SQL
  parameter builders, and GraphQL schema generation so Microsoft SQL Server
  `TINYINT` values flow through the runtime without conversion errors.
- Expanded `SchemaConverterTests` to cover `sbyte` → `SHORT` mapping, ensuring
  GraphQL exposure stays stable.
- Authored supporting docs/scripts (`HOW_TO_USE.md`, database setup utilities)
  to reproduce scenarios that involve tinyint/sbyte columns.

## 2. UInt32 Support

- `TypeHelper` now maps CLR `uint` (`UInt32`) columns to
  `EdmPrimitiveTypeKind.Int64`, preventing “Column type UInt32 not yet supported”
  during metadata discovery.
- SQL/OData parameter parsing accepts unsigned literals via `uint.Parse`, so
  filters and stored procedures operate on unsigned columns.
- GraphQL schema builder exposes `uint` fields as the LONG scalar and serializes
  default metadata using `IntValueNode((long)value)`, keeping the 0–4,294,967,295
  range intact.
- Tests:
  - `SchemaConverterTests` now cover `uint` for both type mapping and default
    value directives.
  - `CLRtoJsonValueTypeUnitTests` assert that `uint` resolves to JSON `number`
    and `DbType.UInt32`.
- Targeted suites executed:
  - `dotnet test src/Service.Tests/Azure.DataApiBuilder.Service.Tests.csproj --filter FullyQualifiedName~SchemaConverter`
  - `dotnet test src/Service.Tests/Azure.DataApiBuilder.Service.Tests.csproj --filter FullyQualifiedName~CLRtoJsonValueTypeUnitTests`

> Reminder: rebuild the solution (`dotnet build src/Azure.DataApiBuilder.sln`)
after pulling these changes so the CLI/runtime bits under `src/out/` pick up the
new type support.

