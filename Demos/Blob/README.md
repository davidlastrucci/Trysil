# Blob Demo

A VCL desktop application demonstrating how to store and retrieve binary data (images) with Trysil.

## Features

- BLOB field mapping (`TBytes` mapped to `varbinary(max)`)
- Batch insert of PNG files from disk into the database
- Image navigation (prior/next) with display
- Optimistic locking via `[TVersionColumn]`

## Prerequisites

- Delphi Enterprise edition (required for SQL Server driver)
- SQL Server instance
- Trysil packages built (see [Setup](../../Docs/Setup.md))

## Setup

1. Run `Sql/SqlServer.sql` on your SQL Server instance to create the `Images` table and sequence.
2. Place PNG files in the `Images/` subfolder (sample images are included).
3. Open `Blob.dproj` in Delphi, build and run.

## Project Structure

| File | Description |
|---|---|
| `Blob.dpr` | Main project file |
| `Blob.Model.pas` | `TTImage` entity (ID, Name, Image as TBytes) |
| `Blob.MainForm.pas` | Main form with write/read/navigate buttons |
| `Blob.PictureHelper.pas` | TPicture helper to load images from byte arrays |
| `Sql/SqlServer.sql` | SQL Server schema |
| `Images/` | Sample PNG files |

## Usage

1. Click **Write Images** to load all PNG files from the `Images/` folder into the database.
2. Click **Read Images** to retrieve all stored images.
3. Use **Prior** and **Next** to navigate through the images.
