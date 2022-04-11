(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Controller.Employee;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Http.Types,
  Trysil.Http.Attributes,

  API.Model.Employee,
  API.Controller;

type

{ TAPIEmployeeController }

  [TUri('/employee')]
  TAPIEmployeeController = class(TAPIReadWriteController<TAPIEmployee>);

implementation

end.
