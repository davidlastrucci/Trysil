(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Exceptions;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ ETInvalidOperationException }

  ETInvalidOperationException = class(EInvalidOpException);

{ ETException }

  ETException = class(Exception);

{ ETDataTypeException }

  ETDataTypeException = class(ETException);

implementation

end.
