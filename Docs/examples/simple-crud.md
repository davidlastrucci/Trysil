---
title: Simple CRUD (SQLite)
---

# Simple CRUD (SQLite)

A complete walkthrough of the **Simple.SQLite** demo application. This is a VCL desktop app that demonstrates basic CRUD operations with SQLite.

## Project Structure

```
Demos/Simple.SQLite/
  Demo.dpr                - Main project file
  Demo.Model.pas          - Entity definition
  Demo.MainForm.pas       - Main form with CRUD
  Demo.EditDialog.pas     - Insert/Edit dialog
  Demo.ListView.pas       - ListView binding
  Demo.DatabaseBuilder.pas - Schema creation
```

## Entity Definition

The entity class maps to a `MasterData` table. Each field is decorated with Trysil attributes for column mapping and validation.

```pascal
unit Demo.Model;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type
  [TTable('MasterData')]
  [TSequence('MasterData')]
  TTMasterData = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(30)]
    [TColumn('Firstname')]
    FFirstname: String;

    [TRequired]
    [TMaxLength(30)]
    [TColumn('Lastname')]
    FLastname: String;

    [TMaxLength(50)]
    [TColumn('Company')]
    FCompany: String;

    [TMaxLength(255)]
    [TEmail]
    [TColumn('Email')]
    FEmail: String;

    [TMaxLength(20)]
    [TColumn('Phone')]
    FPhone: String;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;
  public
    function ToString(): String; override;

    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property Company: String read FCompany write FCompany;
    property Email: String read FEmail write FEmail;
    property Phone: String read FPhone write FPhone;
    property VersionID: TTVersion read FVersionID;
  end;
```

Key points:

- `[TRequired]` on `Firstname` and `Lastname` -- validation will reject empty values.
- `[TMaxLength]` enforces string length limits.
- `[TEmail]` validates email format on the `Email` field.
- `[TVersionColumn]` enables optimistic locking -- updates will fail if another user has modified the record in the meantime.
- `ID` and `VersionID` are read-only properties: Trysil manages them via RTTI on the underlying `strict private` fields.

## Setting Up the Connection

The form constructor creates a SQLite connection, a `TTContext`, and the in-memory list that will hold loaded entities.

```pascal
constructor TMainForm.Create(AOwner: TComponent);
const
  DatabaseName: String = 'Test.db';
begin
  inherited Create(AOwner);
  // Disable pooling for single-user desktop app
  TTFireDACConnectionPool.Instance.Config.Enabled := False;

  FCreateDatabase := not TFile.Exists(DatabaseName);

  // Register and create SQLite connection
  TTSQLiteConnection.RegisterConnection('Test', DatabaseName);
  FConnection := TTSQLiteConnection.Create('Test');
  FContext := TTContext.Create(FConnection);

  FMasterData := TTList<TTMasterData>.Create;
end;
```

Connection pooling is disabled because this is a single-user desktop application. In a server application you would leave it enabled (the default).

## Auto-Creating the Database

If the database file does not exist, the app creates the schema automatically on startup. The SQL script is embedded in the `TDatabaseBuilder` DataModule's DFM file and executed via `TTConnection.Execute`.

```pascal
procedure TMainForm.AfterConstruction;
begin
  inherited AfterConstruction;
  if FCreateDatabase then
    TDatabaseBuilder.BuildDatabase(FConnection);
end;
```

```pascal
class procedure TDatabaseBuilder.BuildDatabase(
  const AConnection: TTConnection);
var
  LDatabaseBuilder: TDatabaseBuilder;
begin
  LDatabaseBuilder := TDatabaseBuilder.Create(nil);
  try
    AConnection.Execute(LDatabaseBuilder.GetScript());
  finally
    LDatabaseBuilder.Free;
  end;
end;
```

## Loading Data (SelectAll)

`SelectAll<T>` loads every row from the mapped table into the provided list. The list is an `TTList<TTMasterData>` (which extends `TObjectList<T>` with `OwnsObjects = True`), so previously loaded entities are freed automatically when the list is repopulated.

```pascal
procedure TMainForm.OpenButtonClick(Sender: TObject);
begin
  FContext.SelectAll<TTMasterData>(FMasterData);
  RefreshListView;
end;
```

## Inserting a Record

Inserting uses a modal dialog. The flow is:

1. `CreateEntity<T>` allocates a new entity with default values.
2. The user fills in the form fields.
3. `Insert<T>` persists the entity to the database (validation runs automatically).
4. The entity is added to the in-memory list.

```pascal
class function TEditDialog.Insert(
  const AContext: TTContext; const AList: TTList<TTMasterData>): Boolean;
var
  LDialog: TEditDialog;
  LEntity: TTMasterData;
begin
  LDialog := TEditDialog.Create(AContext, AList, nil);
  try
    result := (LDialog.ShowModal = mrOk);
    if result then
    begin
      LEntity := AContext.CreateEntity<TTMasterData>();
      LDialog.BindControlsToEntity(LEntity);
      AContext.Insert<TTMasterData>(LEntity);
      AList.Add(LEntity);
    end;
  finally
    LDialog.Free;
  end;
end;
```

!!! note
    Always use `CreateEntity<T>` to create new entities. Do not call `TTMasterData.Create` directly -- `CreateEntity<T>` initializes internal ORM state (sequence ID, version column) that the resolver needs.

## Updating a Record

Updating follows the same dialog pattern. The existing entity is passed to the dialog, the user edits the fields, and `Update<T>` persists the changes.

```pascal
class function TEditDialog.Edit(
  const AContext: TTContext;
  const AList: TTList<TTMasterData>;
  const AEntity: TTMasterData): Boolean;
var
  LDialog: TEditDialog;
begin
  LDialog := TEditDialog.Create(AContext, AList, AEntity);
  try
    result := (LDialog.ShowModal = mrOk);
    if result then
    begin
      LDialog.BindControlsToEntity(AEntity);
      AContext.Update<TTMasterData>(AEntity);
    end;
  finally
    LDialog.Free;
  end;
end;
```

The `[TVersionColumn]` attribute enables optimistic locking. If another user has modified the same record since it was loaded, the update will fail with an exception rather than silently overwriting their changes.

## Deleting a Record

The delete handler gets the selected entity from the ListView, asks for confirmation, then calls `Delete<T>` and removes the entity from the in-memory list.

```pascal
procedure TMainForm.DeleteButtonClick(Sender: TObject);
var
  LEntity: TTMasterData;
begin
  LEntity := FMasterDataListView.SelectedEntity;
  if Assigned(LEntity) then
    if Application.MessageBox(
      PChar(Format('Eliminare "%s"?', [LEntity.ToString()])),
      'Conferma',
      MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) = IDYES then
    begin
      FContext.Delete<TTMasterData>(LEntity);
      FMasterData.Remove(LEntity);
      RefreshListView;
    end;
end;
```

## ListView Binding

The demo uses `TTListView<T>` from `Trysil.Vcl.ListView` -- a generic VCL ListView wrapper that binds entity lists to columns via property names. The `TTMasterDataListView` subclass adds columns and an optional client-side search predicate.

```pascal
TTMasterDataListView = class(TTListView<TTMasterData>)
public
  procedure BindData(
    const AData: TTList<TTMasterData>; const ASearchText: String);
end;
```

Columns are defined in `AfterConstruction`:

```pascal
procedure TTMasterDataListView.AddColumns;
begin
  AddColumn(SID, taLeftJustify, 50, 'ID');
  AddColumn(SFirstName, taLeftJustify, 150, 'FirstName');
  AddColumn(SLastName, taLeftJustify, 150, 'LastName');
  AddColumn(SCompany, taLeftJustify, 200, 'Company');
  AddColumn(SEmail, taLeftJustify, 200, 'Email');
  AddColumn(SPhone, taRightJustify, 120, 'Phone');
  PrepareColumns;
end;
```

The search box filters the list client-side using an anonymous predicate:

```pascal
function TTMasterDataListView.GetPredicate(
  const ASearchText: String): TTPredicate<TTMasterData>;
var
  LSearchText: String;
begin
  result := nil;
  if not ASearchText.IsEmpty then
  begin
    LSearchText := ASearchText.ToLower();
    result := function(const AItem: TTMasterData): Boolean
    begin
      result :=
        AItem.Firstname.ToLower().Contains(LSearchText) or
        AItem.Lastname.ToLower().Contains(LSearchText) or
        AItem.Company.ToLower().Contains(LSearchText) or
        AItem.Email.ToLower().Contains(LSearchText) or
        AItem.Phone.ToLower().Contains(LSearchText);
    end;
  end;
end;
```

## Cleanup

All owned objects are freed in reverse creation order. Because `TTList<T>` owns its objects, freeing the list also frees every entity in it.

```pascal
destructor TMainForm.Destroy;
begin
  FMasterDataListView.Free;
  FMasterData.Free;
  FContext.Free;
  FConnection.Free;
  inherited Destroy;
end;
```

!!! tip
    The demo project enables `ReportMemoryLeaksOnShutdown := True` in the `.dpr` file. This is a good practice during development to catch any entities or connections that are not properly freed.

## Running the Demo

1. Open `Demos/Simple.SQLite/Demo.dproj` in the Delphi IDE.
2. Build and run -- the `Test.db` database file is created automatically on first launch.
3. Click **Open** to load data, then use the **Insert**, **Edit**, and **Delete** buttons.
4. Use the search box to filter the ListView client-side.
