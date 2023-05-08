<p align="center">
  <img width="300" height="292" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil.png" title="Trysil - Operation ORM">
</p>

# Trysil
> **Trysil**<br>
> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

## Using *Trysil*

### Interface
<pre>

{ TDemo }

  TDemo = class
  strict private
    FConnection: TTConnection;
    FContext: TTContext;
    
    procedure Insert(const APersonalData: TPersonalData);
    procedure Update(const APersonalData: TPersonalData);
    procedure Delete(const APersonalData: TPersonalData);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute;
  end;
</pre>

### Implementation
<pre>
{ TDemo }

constructor TDemo.Create;
begin
  inherited Create;
  TTSqlServerConnection.RegisterConnection(
    'Test', '127.0.0.1', 'DatabaseName');
  FConnection := TTSqlServerConnection.Create('Test');
  FContext := TTContext.Create(FConnection);
end;

destructor TDemo.Destroy;
begin
  FContext.Free;
  FConnection.Free;
  inherited Destroy;
end;

procedure TDemo.Insert(const APersonalData: TPersonalData);
begin
  APersonalData.Firstname := 'Stephen';
  APersonalData.Lastname := 'Silvermann';
  FContext.Insert&lt;TPersonalData&gt;(APersonalData);
end;

procedure TDemo.Update(const APersonalData: TPersonalData);
begin
  APersonalData.Company := 'Dynabox';
  APersonalData.Email := 'stephen.silvermann@dynabox.com';
  FContext.Update&lt;TPersonalData&gt;(APersonalData);
end;

procedure TDemo.Delete(const APersonalData: TPersonalData);
begin
  FContext.Delete&lt;TPersonalData&gt;(APersonalData);
end;

procedure TDemo.Execute;
var
  LPersonalData: TPersonalData;
begin
  LPersonalData := FContext.CreateEntity&lt;TPersonalData&gt;();
  Insert(LPersonalData);
  Update(LPersonalData);
  Delete(LPersonalData);
end;
</pre>

---

[https://www.lastrucci.net/](https://www.lastrucci.net)
