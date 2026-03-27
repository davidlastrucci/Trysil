# Simple Demo (SQL Server)

A VCL desktop application demonstrating basic CRUD operations with Trysil and SQL Server.

## Features

- Entity mapping with validation attributes (`[TRequired]`, `[TMaxLength]`, `[TEmail]`)
- SelectAll, Insert, Update, Delete via `TTContext`
- Real-time search filtering on the ListView
- Optimistic locking via `[TVersionColumn]`
- Connection pooling via FireDAC
- JSON-based connection configuration

## Prerequisites

- Delphi Enterprise edition (required for SQL Server driver)
- SQL Server instance
- Trysil packages built (see [Setup](../../Docs/Setup.md))

## Setup

1. Run `Sql/Demo.sql` on your SQL Server instance to create the `MasterData` table, sequence, and sample data (73+ records).

2. Create a `Demo.config.json` file in the executable output directory:

   ```json
   {
     "connections": [
       {
         "name": "Test",
         "server": "YourServer",
         "username": "",
         "password": "",
         "databaseName": "YourDatabase"
       }
     ]
   }
   ```

3. Open `Demo.dproj` in Delphi, build and run.

## Project Structure

| File | Description |
|---|---|
| `Demo.dpr` | Main project file |
| `Demo.Config.pas` | JSON configuration loader |
| `Demo.Model.pas` | `TTMasterData` entity (maps to `MasterData` table) |
| `Demo.MainForm.pas` | Main form with CRUD buttons and search |
| `Demo.EditDialog.pas` | Modal dialog for insert/edit |
| `Demo.ListView.pas` | Generic ListView binding with column sorting |
| `Sql/Demo.sql` | SQL Server schema and sample data |

## Usage

1. Click **Open** to load all records from the database.
2. Use the search box to filter by any field.
3. Use **Insert**, **Edit**, and **Delete** buttons for CRUD operations.
