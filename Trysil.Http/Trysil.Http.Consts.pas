(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Consts;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ TTHttpStatusCodeTypes }

  TTHttpStatusCodeTypes = class
  public
    const OK: Integer = 200;
    const Created: Integer = 201;
    const BadRequest: Integer = 400;
    const Unauthorized: Integer = 401;
    const Forbidden: Integer = 403;
    const NotFound: Integer = 404;
    const MethodNotAllowed: Integer = 405;
    const InternalServerError: Integer = 500;
  end;

{ TTHttpContentTypes }

  TTHttpContentTypes = class
  public
    const Bmp: String = 'image/bmp';
    const Css: String = 'text/css';
    const Gif: String = 'image/gif';
    const Html: String = 'text/html';
    const JPeg: String = 'image/jpeg';
    const JScript: String = 'application/javascript';
    const JSon: String = 'application/json';
    const Pdf: String = 'application/pdf';
    const Png: String = 'image/png';
    const Stream: String = 'application/octet-stream';
    const Text: String = 'text/plain';
    const Xml: String = 'application/xml';
    const Zip: String = 'application/zip';
  end;

{ TTHttpContentEncodingTypes }

  TTHttpContentEncodingTypes = class
  public
    const Ansi: String = 'ansi';
    const Ascii: String = 'ascii';
    const Iso88591: String = 'iso-8859-1';
    const Utf8: String = 'utf-8';
  end;

resourcestring
  SLogWriterAlreadyRegistered = 'LogWriter: class already registered.';
  SNotValidLogWriter = 'LogWriter %s is not a valid TTHttpLogAbstractWriter.';
  SAuthAlreadyRegistered = 'Authentication: class already registered.';
  SNotValidAuthentication = 'Authentication %s is not a valid TTHttpAbstractAuthentication.';
  SNotValidController = 'Controller %s is not a valid TTHttpAbstractController.';
  SDuplicateController = 'Duplicate ControllerID(Uri/MethodType): %0:s.';
  SAlreadyStarted = 'Http server already started.';
  SNotStarted = 'Http server not started.';
  SNotValidCommandType = 'Not valid command type %s.';
  SNotFound = 'Command %s not found.';
  SMethodNotAllowed = 'Method %0:s not allowed for command %1:s.';
  SUnauthorized = 'Access unauthorized: %s.';
  SForbidden = 'Acess forbidden : %s.';
  SForbiddenArea = 'Access forbidden: %0:s - Area: %1:s.';
  SOrderByNotValid = 'ORDER BY Clause %s not valid.';
  SColumnNotFound = 'Column %s not found.';
  SConditionNotValid = 'Condition %s not valid.';
  SDirectionNotValid = 'Direction %s not valid.';

implementation

end.
