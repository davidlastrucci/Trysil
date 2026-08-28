(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Log.Model;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Http.Log.Types;

type

{ TLogAction }

  [TTable('log.Actions')]
  [TSequence('log.ActionsID')]
  TLogAction = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('TaskID')]
    FTaskID: String;

    [TColumn('Date')]
    FDate: TDateTime;

    [TColumn('Action')]
    FAction: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const AAction: TTHttpLogAction);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property Date: TDateTime read FDate;
    property Action: String read FAction;
    property VersionID: TTVersion read FVersionID;
  end;

{ TLogRequest }

  [TTable('log.Requests')]
  [TSequence('log.RequestsID')]
  TLogRequest = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('TaskID')]
    FTaskID: String;

    [TColumn('Date')]
    FDate: TDateTime;

    [TColumn('Uri')]
    FUri: String;

    [TColumn('Params')]
    FParams: String;

    [TColumn('MethodType')]
    FMethodType: String;

    [TColumn('ContentLength')]
    FContentLength: Int64;

    [TColumn('ContentOmitted')]
    FContentOmitted: Boolean;

    [TColumn('Content')]
    FContent: String;

    [TColumn('Headers')]
    FHeaders: String;

    [TColumn('RemoteIP')]
    FRemoteIP: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const ARequest: TTHttpLogRequest);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property Date: TDateTime read FDate;
    property Uri: String read FUri;
    property Params: String read FParams;
    property MethodType: String read FMethodType;
    property ContentLength: Int64 read FContentLength;
    property ContentOmitted: Boolean read FContentOmitted;
    property Content: String read FContent;
    property Headers: String read FHeaders;
    property RemoteIP: String read FRemoteIP;
    property VersionID: TTVersion read FVersionID;
  end;

{ TLogResponses }

  [TTable('log.Responses')]
  [TSequence('log.ResponsesID')]
  TLogResponse = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('TaskID')]
    FTaskID: String;

    [TColumn('Date')]
    FDate: TDateTime;

    [TColumn('Username')]
    FUsername: String;

    [TColumn('UserAreas')]
    FUserAreas: String;

    [TColumn('StatusCode')]
    FStatusCode: Integer;

    [TColumn('ContentType')]
    FContentType: String;

    [TColumn('ContentEncoding')]
    FContentEncoding: String;

    [TColumn('ContentLength')]
    FContentLength: Int64;

    [TColumn('ContentOmitted')]
    FContentOmitted: Boolean;

    [TColumn('Content')]
    FContent: String;

    [TColumn('BinaryContent')]
    FBinaryContent: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const AResponse: TTHttpLogResponse);

    property ID: TTPrimaryKey read FID;
    property TaskID: String read FTaskID;
    property Date: TDateTime read FDate;
    property Username: String read FUsername;
    property UserAreas: String read FUserAreas;
    property StatusCode: Integer read FStatusCode;
    property ContentType: String read FContentType;
    property ContentEncoding: String read FContentEncoding;
    property ContentLength: Int64 read FContentLength;
    property ContentOmitted: Boolean read FContentOmitted;
    property Content: String read FContent;
    property BinaryContent: String read FBinaryContent;
    property VersionID: TTVersion read FVersionID;
  end;

{ TLogDiscarded }

  [TTable('log.Discarded')]
  [TSequence('log.DiscardedID')]
  TLogDiscarded = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Date')]
    FDate: TDateTime;

    [TColumn('Host')]
    FHost: String;

    [TColumn('Entries')]
    FEntries: Integer;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    procedure SetValues(const ADiscarded: TTHttpLogDiscarded);

    property ID: TTPrimaryKey read FID;
    property Date: TDateTime read FDate;
    property Host: String read FHost;
    property Entries: Integer read FEntries;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TLogAction }

procedure TLogAction.SetValues(const AAction: TTHttpLogAction);
begin
  FTaskID := AAction.TaskID;
  FDate := AAction.DateTime;
  FAction := AAction.Action;
end;

{ TLogRequest }

procedure TLogRequest.SetValues(const ARequest: TTHttpLogRequest);
begin
  FTaskID := ARequest.TaskID.ToString;
  FDate := ARequest.DateTime;
  FUri := ARequest.Uri;
  FParams := ARequest.Params.ToString;
  FMethodType := ARequest.MethodType;
  FContentLength := ARequest.ContentLength;
  FContentOmitted := ARequest.ContentOmitted;
  FContent := ARequest.Content;
  FHeaders := ARequest.Headers.ToString;
  FRemoteIP := ARequest.RemoteIP;
end;

{ TLogResponse }

procedure TLogResponse.SetValues(const AResponse: TTHttpLogResponse);
begin
  FTaskID := AResponse.TaskID.ToString;
  FDate := AResponse.DateTime;
  FUsername := AResponse.User.Username;
  FUserAreas := AResponse.User.Areas.ToString;
  FStatusCode := AResponse.StatusCode;
  FContentType := AResponse.ContentType;
  FContentEncoding := AResponse.ContentEncoding;
  FContentLength := AResponse.ContentLength;
  FContentOmitted := AResponse.ContentOmitted;
  FContent := AResponse.Content;
  FBinaryContent := AResponse.BinaryContent;
end;

{ TLogDiscarded }

procedure TLogDiscarded.SetValues(const ADiscarded: TTHttpLogDiscarded);
begin
  FDate := TTimeZone.Local.ToUniversalTime(Now);
  FHost := ADiscarded.Host;
  FEntries := ADiscarded.Count;
end;

end.
