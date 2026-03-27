# Simple Demo (SQLite)

A VCL desktop application demonstrating basic CRUD operations with Trysil and SQLite. This is the easiest demo to run -- no external database required.

## Features

- Entity mapping with validation attributes (`[TRequired]`, `[TMaxLength]`, `[TEmail]`)
- SelectAll, Insert, Update, Delete via `TTContext`
- Real-time search filtering on the ListView
- Optimistic locking via `[TVersionColumn]`
- Automatic database creation on first run

## Prerequisites

- Delphi Community edition (or higher)
- Trysil packages built (see [Setup](../../Docs/Setup.md))

## Setup

1. Open `Demo.dproj` in Delphi.
2. Build and run -- the `Test.db` SQLite database is created automatically on first launch.

No configuration file or external database needed.

## Project Structure

| File | Description |
|---|---|
| `Demo.dpr` | Main project file |
| `Demo.Model.pas` | `TTMasterData` entity (maps to `MasterData` table) |
| `Demo.MainForm.pas` | Main form with CRUD buttons and search |
| `Demo.DatabaseBuilder.pas` | Auto-creates SQLite schema on first run |
| `Demo.EditDialog.pas` | Modal dialog for insert/edit |
| `Demo.ListView.pas` | Generic ListView binding with column sorting |

## Usage

1. Click **Open** to load all records from the database.
2. Use the search box to filter by any field.
3. Use **Insert**, **Edit**, and **Delete** buttons for CRUD operations.
