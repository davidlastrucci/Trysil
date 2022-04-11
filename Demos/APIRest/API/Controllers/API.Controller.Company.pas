(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Controller.Company;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Http.Types,
  Trysil.Http.Attributes,

  API.Model.Company,
  API.Controller;

type

{ TAPICompanyController }

  [TUri('/company')]
  TAPICompanyController = class(TAPIReadWriteController<TAPICompany>);

implementation

end.
