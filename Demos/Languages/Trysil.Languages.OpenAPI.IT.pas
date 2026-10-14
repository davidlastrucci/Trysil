unit Trysil.Languages.OpenAPI.IT;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,
  Trysil.OpenAPI.Consts;

type

{ TTLanguageOpenApiIT }

  TTLanguageOpenApiIT = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageOpenApiIT }

class procedure TTLanguageOpenApiIT.Translate;
begin
  TTLanguage.Instance.Add(SOpenApiServerStarted, 'OpenAPI: il documento non può essere registrato su un server già avviato.');
  TTLanguage.Instance.Add(SOpenApiAlreadyRegistered, 'OpenAPI: il documento è già registrato su questo server.');
  TTLanguage.Instance.Add(SOpenApiContextAlreadyRegistered, 'OpenAPI: il documento di questo contesto è già registrato su un altro server.');
  TTLanguage.Instance.Add(SOpenApiEmptyTitle, 'OpenAPI: il titolo del documento è vuoto.');
  TTLanguage.Instance.Add(SOpenApiEmptyVersion, 'OpenAPI: la versione del documento è vuota.');
  TTLanguage.Instance.Add(SOpenApiNoEntityClass, 'OpenAPI: %0:s.%1:s descrive l''entità del suo controller, ma il controller non ha EntityClass.');
  TTLanguage.Instance.Add(SOpenApiPageRequestBody, 'OpenAPI: %0:s.%1:s dichiara un request body con la forma Page.');
end;

end.
