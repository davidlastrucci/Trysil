unit Trysil.Languages.OpenAPI.FR;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,
  Trysil.OpenAPI.Consts;

type

{ TTLanguageOpenApiFR }

  TTLanguageOpenApiFR = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageOpenApiFR }

class procedure TTLanguageOpenApiFR.Translate;
begin
  TTLanguage.Instance.Add(SOpenApiServerStarted, 'OpenAPI : le document ne peut pas être enregistré sur un serveur déjà démarré.');
  TTLanguage.Instance.Add(SOpenApiAlreadyRegistered, 'OpenAPI : le document est déjà enregistré sur ce serveur.');
  TTLanguage.Instance.Add(SOpenApiContextAlreadyRegistered, 'OpenAPI : le document de ce contexte est déjà enregistré sur un autre serveur.');
  TTLanguage.Instance.Add(SOpenApiEmptyTitle, 'OpenAPI : le titre du document est vide.');
  TTLanguage.Instance.Add(SOpenApiEmptyVersion, 'OpenAPI : la version du document est vide.');
  TTLanguage.Instance.Add(SOpenApiNoEntityClass, 'OpenAPI : %0:s.%1:s décrit l''entité de son contrôleur, mais le contrôleur n''a pas d''EntityClass.');
  TTLanguage.Instance.Add(SOpenApiPageRequestBody, 'OpenAPI : %0:s.%1:s déclare un corps de requête avec la forme Page.');
end;

end.
