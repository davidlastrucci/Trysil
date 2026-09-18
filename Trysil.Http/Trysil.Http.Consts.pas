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
  System.Math,
  System.StrUtils,
  System.Hash,
  System.Generics.Defaults,
  System.Generics.Collections,
  Trysil.Consts,
  Trysil.Classes,
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
    const Conflict: Integer = 409;
    const ContentTooLarge: Integer = 413;
    const UnprocessableContent: Integer = 422;
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

{ TTHttpServerHeader }

  TTHttpServerHeader = class
  public
    const Default: String = 'API REST made simple by Trysil Delphi ORM - ' +
      'https://github.com/davidlastrucci/Trysil';
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
    FLock: TTMultiReadExclusiveWriteLock;
    FStrings: TDictionary<TTLanguageValue, String>;

    class function ParseAcceptLanguage(
      const AValue: String): TArray<String>; static;
    class function QualityOf(const AItem: String): Double; static;
  strict protected
    function GetCurrentLanguage: String; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure SetThreadLanguage(const ALanguage: String);
    procedure RemoveThreadLanguage;

    procedure Add(
      const ALanguage: String;
      const AKey: String;
      const AValue: String);

    function TryTranslate(
      const AKey: String; out AValue: String): Boolean; override;

    class property Instance: TTHttpLanguage read FInstance;
  end;

resourcestring
  SAreasNeedAuthentication = 'A route restricted with [TArea] needs an ' +
    'authentication class: register one, or remove the attribute.';
  SAreaOnAnonymousRoute = 'Route %0:s is restricted with [TArea] and open ' +
    'with [TAuthorizationType(None)]: nobody can ever reach it.';
  SLogWriterAlreadyRegistered = 'LogWriter: class already registered.';
  SNotValidLogWriter = 'LogWriter %s is not a valid TTHttpLogAbstractWriter.';
  SAuthAlreadyRegistered = 'Authentication: class already registered.';
  SNotValidAuthentication = 'Authentication %s is not a valid TTHttpAbstractAuthentication.';
  SNotValidController = 'Controller %s is not a valid TTHttpAbstractController.';
  SDuplicateController = 'Duplicate ControllerID(Uri/MethodType): %0:s.';
  SAuthenticationNotRegistered = 'Http server not started: one or more ' +
    'controllers require authentication and no authentication class is ' +
    'registered. A route without [TAuthorizationType] requires ' +
    'authentication by default. Call RegisterAuthentication, or set ' +
    'AllowAnonymous to True if this server is meant to serve every route ' +
    'anonymously.';
  SNotValidParametrizedUri = 'Route %0:s carries a "?" that is not in ' +
    'the last segments. A placeholder matches any value, so one placed ' +
    'before a fixed segment makes the route overlap addresses it was ' +
    'never meant to serve. Move the placeholders to the end of the route.';
  SNotValidBaseUri = 'BaseUri %0:s is a path prefix, not an address: it ' +
    'is prepended to every route, so a value carrying a scheme registers ' +
    'routes nobody can reach. The address the server listens on comes ' +
    'from Bindings.';
  SEmptyJWTSecret = 'The HMAC secret is empty: every signature it makes ' +
    'can be reproduced by anyone, so a token signed with it proves ' +
    'nothing. Return a real secret from GetSecret.';
  SAlreadyStarted = 'Http server already started.';
  SNotStarted = 'Http server not started.';
  SRedactedNamesWhileServing = 'The redaction list cannot be changed while ' +
    'a server is running: it is read on every header and every parameter ' +
    'of every request, and adding to it under those readers is a race. ' +
    'Name what must not be logged before Start.';
  SUnhandledRequestError = 'Unhandled %0:s outside the request ' +
    'handler: %1:s';
  SStartWithoutLimit = 'A "start" of %0:d needs a "limit": the endpoint ' +
    'is configured without a maximum page size, so there is nothing to ' +
    'fall back to.';
  SNotValidFilterContent = 'A filter is a JSon object. This body parses ' +
    'to something else, and none of "where", "orderBy", "start" or ' +
    '"limit" can be read from it: applying it would silently mean no ' +
    'filter at all, and a filter that is dropped is a restriction that ' +
    'is dropped.';
  SNoSaveOnHttpContext = 'Save is not available on a TTHttpContext. It ' +
    'decides between an insert and an update from what the context ' +
    'created and has not written yet, and a context that lives one ' +
    'request has no such history: the entity was filled from the body. ' +
    'Whether the request is a create or an update is in the request, so ' +
    'call Insert or Update.';
  SNotValidTenantName = 'Tenant name "%0:s" is not a name: it has to ' +
    'start with a letter or a digit, hold at most 63 of them plus "_", ' +
    '"-" and ".", and nothing else. The name reaches a connection ' +
    'definition and, in most applications, a database name or a path, ' +
    'and it usually arrives from the request.';
  SContentTooLarge = 'The request body is larger than the %0:d bytes ' +
    'this server accepts. A body is read into memory whole before ' +
    'anything looks at it, so the ceiling is what keeps one request from ' +
    'costing the process more than it has. Raise ' +
    'MaxRequestContentLength, or set it to zero to accept any size.';
  SMethodOverrideRefused = 'The request asks to be treated as %0:s while ' +
    'it was sent as %1:s. A method carried in a header travels past ' +
    'anything that filters on the request line, so the server refuses it. ' +
    'Set AllowMethodOverride to True if this server is meant to honour it.';
  SNotValidCommandType = 'Not valid command type %s.';
  SNotFound = 'Command %s not found.';
  SEntityNotFound = 'Entity %d not found.';
  SMethodNotAllowed = 'Method %0:s not allowed for command %1:s.';
  SUnauthorized = 'Access unauthorized: %s.';
  SForbidden = 'Access forbidden: %s.';
  SForbiddenAreaLog = 'Access forbidden: %0:s - missing area: %1:s.';
  SOrderByNotValid = 'ORDER BY Clause %s not valid.';
  SNotValidFilterValue = 'Field "%s" of the filter carries a value the ' +
    'filter cannot read. A filter that cannot be read is refused, not ' +
    'applied in part.';
  SConditionNotValid = 'Condition %s not valid.';
  SDirectionNotValid = 'Direction %s not valid.';
  SValueNotValid = 'Value %0:s not valid for column %1:s.';
  SColumnNotFilterable = 'Column %s cannot be used in a filter: it is not ' +
    'a column of this entity, or it is marked as not filterable.';
  SConditionNotValidForColumn =
    'Condition %0:s not valid for column %1:s.';
  SWhereNotValid = 'WHERE Clause not valid.';
  SOrderByItemNotValid = 'ORDER BY Clause not valid.';
  STooManyWhereConditions =
    'Too many WHERE conditions: %0:d (maximum %1:d).';
  STooManyOrderByColumns =
    'Too many ORDER BY columns: %0:d (maximum %1:d).';
  SInternalServerError = 'Internal server error.';
  SNotValidJSonContent = 'The request body is not valid JSON. A body that ' +
    'cannot be parsed is refused rather than read as an empty object: a ' +
    'filter built from an empty object carries no condition at all, and the ' +
    'endpoint would answer with the whole table.';

implementation

threadvar
  FThreadLanguages: TArray<String>;

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
    TTIdentifier.Same(ALeft.Language, ARight.Language) and
    TTIdentifier.Same(ALeft.Key, ARight.Key);
end;

function TTLanguageValueEqualityComparer.GetHashCode(
  const AValue: TTLanguageValue): Integer;
begin
  result := THashBobJenkins.GetHashValue(Format('%s|%s', [
    AValue.Language.ToUpperInvariant,
    AValue.Key.ToUpperInvariant]));
end;

{ TTHttpLanguage }

class constructor TTHttpLanguage.ClassCreate;
begin
  FInstance := TTHttpLanguage.Create;
end;

class destructor TTHttpLanguage.ClassDestroy;
begin
  if TTLanguage.Instance.Resolver = FInstance then
    TTLanguage.Instance.Resolver := nil;
  FInstance.Free;
  FInstance := nil;
end;

constructor TTHttpLanguage.Create;
begin
  inherited Create;
  FLock := TTMultiReadExclusiveWriteLock.Create;
  FStrings := TDictionary<TTLanguageValue, String>.Create(
    TTLanguageValueEqualityComparer.Create);
end;

destructor TTHttpLanguage.Destroy;
begin
  FStrings.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TTHttpLanguage.AfterConstruction;
begin
  inherited AfterConstruction;
  TTLanguage.Instance.Resolver := Self;
end;

class function TTHttpLanguage.QualityOf(const AItem: String): Double;
var
  LIndex: Integer;
  LQuality: String;
begin
  result := 1;
  LIndex := AItem.ToLower().IndexOf(';q=');
  if LIndex >= 0 then
  begin
    LQuality := AItem.Substring(LIndex + 3).Trim;
    if not TryStrToFloat(LQuality, result, TFormatSettings.Invariant) then
      result := 1;
  end;
end;

class function TTHttpLanguage.ParseAcceptLanguage(
  const AValue: String): TArray<String>;
var
  LItems: TList<String>;
  LItem: String;
  LTag: String;
  LPrimary: String;
begin
  LItems := TList<String>.Create;
  try
    for LItem in AValue.Split([',']) do
      if not LItem.Trim.IsEmpty then
        LItems.Add(LItem.Trim);

    LItems.Sort(TComparer<String>.Construct(
      function(const ALeft, ARight: String): Integer
      begin
        result := CompareValue(QualityOf(ARight), QualityOf(ALeft));
      end));

    result := [];
    for LItem in LItems do
    begin
      LTag := LItem.Split([';'])[0].Trim;
      if LTag.IsEmpty or LTag.Equals('*') then
        Continue;

      if IndexStr(LTag, result) < 0 then
        result := result + [LTag];

      LPrimary := LTag.Split(['-'])[0];
      if (not LPrimary.Equals(LTag)) and (IndexStr(LPrimary, result) < 0) then
        result := result + [LPrimary];
    end;
  finally
    LItems.Free;
  end;
end;

procedure TTHttpLanguage.SetThreadLanguage(const ALanguage: String);
begin
  FThreadLanguages := ParseAcceptLanguage(ALanguage);
end;

procedure TTHttpLanguage.RemoveThreadLanguage;
begin
  FThreadLanguages := nil;
end;

function TTHttpLanguage.GetCurrentLanguage: String;
begin
  result := String.Empty;
  if Length(FThreadLanguages) > 0 then
    result := FThreadLanguages[0];
end;

procedure TTHttpLanguage.Add(
  const ALanguage: String; const AKey: String; const AValue: String);
begin
  FLock.BeginWrite;
  try
    FStrings.AddOrSetValue(TTLanguageValue.Create(ALanguage, AKey), AValue);
  finally
    FLock.EndWrite;
  end;
end;

function TTHttpLanguage.TryTranslate(
  const AKey: String; out AValue: String): Boolean;
var
  LLanguage: String;
begin
  result := False;
  FLock.BeginRead;
  try
    for LLanguage in FThreadLanguages do
    begin
      result := FStrings.TryGetValue(
        TTLanguageValue.Create(LLanguage, AKey), AValue);
      if result then
        Break;
    end;
  finally
    FLock.EndRead;
  end;
end;

end.
