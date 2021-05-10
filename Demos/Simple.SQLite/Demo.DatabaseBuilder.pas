unit Demo.DatabaseBuilder;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Trysil.Data;

type

{ TDatabaseBuilder }

  TDatabaseBuilder = class(TDataModule)
    ScriptQuery: TFDQuery;
  strict private
    function GetScript: String;
  public
    class procedure BuildDatabase(const AConnection: TTConnection);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TDatabaseBuilder }

function TDatabaseBuilder.GetScript: String;
begin
  result := ScriptQuery.SQL.Text;
end;

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

end.
