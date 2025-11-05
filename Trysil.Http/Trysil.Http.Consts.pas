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
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  Trysil.Consts,
  Trysil.Sync;

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

{ TTLanguageValue }

  TTLanguageValue = record
  strict private
    FLanguage: String;
    FKey: String;
  public
    constructor Create(const ALanguage: String; const AKey: String);

    property Language: String read FLanguage;
    property Key: String read FKey;
  end;

{ TTLanguageValueEqualityComparer }

  TTLanguageValueEqualityComparer = class(TEqualityComparer<TTLanguageValue>)
  public
    function Equals(
      const ALeft: TTLanguageValue;
      const ARight: TTLanguageValue): Boolean; override;
    function GetHashCode(const AValue: TTLanguageValue): Integer; override;
  end;

{ TTHttpLanguage }

  TTHttpLanguage = class(TTAbstractLanguageResolver)
  strict private
    class var FInstance: TTHttpLanguage;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FCriticalSection: TTCriticalSection;
    FThreads: TDictionary<TThreadID, String>;
    FStrings: TDictionary<TTLanguageValue, String>;
  strict protected
    function GetCurrentLanguage: String; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure SetThreadLanguage(
      const AThreadID: TThreadID; const ALanguage: String);
    procedure RemoveThreadLanguage(const AThreadID: TThreadID);

    procedure Add(
      const ALanguage: String;
      const AKey: String;
      const AValue: String);

    function TryTranslate(
      const AKey: String; out AValue: String): Boolean; override;

    class property Instance: TTHttpLanguage read FInstance;
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

{ TTLanguageValue }

constructor TTLanguageValue.Create(
  const ALanguage: String; const AKey: String);
begin
  FLanguage := ALanguage;
  FKey := AKey;
end;

{ TTLanguageValueEqualityComparer }

function TTLanguageValueEqualityComparer.Equals(
  const ALeft: TTLanguageValue; const ARight: TTLanguageValue): Boolean;
begin
  result :=
    (String.Compare(ALeft.Language, ARight.Language, True) = 0) and
    (String.Compare(ALeft.Key, ARight.Key, True) = 0);
end;

function TTLanguageValueEqualityComparer.GetHashCode(
  const AValue: TTLanguageValue): Integer;
begin
  result := AValue.Language.Length + AValue.Key.Length;
end;

{ TTHttpLanguage }

class constructor TTHttpLanguage.ClassCreate;
begin
  FInstance := TTHttpLanguage.Create;
end;

class destructor TTHttpLanguage.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTHttpLanguage.Create;
begin
  inherited Create;
  FCriticalSection := TTCriticalSection.Create;
  FThreads := TDictionary<TThreadID, String>.Create;
  FStrings := TDictionary<TTLanguageValue, String>.Create(
    TTLanguageValueEqualityComparer.Create);
end;

destructor TTHttpLanguage.Destroy;
begin
  FStrings.Free;
  FThreads.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTHttpLanguage.AfterConstruction;
begin
  inherited AfterConstruction;
  TTLanguage.Instance.Resolver := Self;
end;

procedure TTHttpLanguage.SetThreadLanguage(
  const AThreadID: TThreadID; const ALanguage: String);
begin
  FCriticalSection.Acquire;
  try
    FThreads.AddOrSetValue(AThreadID, ALanguage);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TTHttpLanguage.RemoveThreadLanguage(const AThreadID: TThreadID);
begin
  FCriticalSection.Acquire;
  try
    FThreads.Remove(AThreadID);
  finally
    FCriticalSection.Leave;
  end;
end;

function TTHttpLanguage.GetCurrentLanguage: String;
begin
  FCriticalSection.Acquire;
  try
    if not FThreads.TryGetValue(TThread.Current.ThreadID, result) then
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TTHttpLanguage.Add(
  const ALanguage: String; const AKey: String; const AValue: String);
begin
  FStrings.AddOrSetValue(TTLanguageValue.Create(ALanguage, AKey), AValue);
end;

function TTHttpLanguage.TryTranslate(
  const AKey: String; out AValue: String): Boolean;
var
  LLanguage: String;
  LKey: TTLanguageValue;
begin
  FCriticalSection.Acquire;
  try
    result := FThreads.TryGetValue(TThread.Current.ThreadID, LLanguage);
  finally
    FCriticalSection.Leave;
  end;

  if result then
  begin
    LKey := TTLanguageValue.Create(LLanguage, AKey);
    result := FStrings.TryGetValue(LKey, AValue);
  end;
end;

end.
