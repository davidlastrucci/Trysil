<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Dark.png">
    <img img width="300" height="107" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Light.png" alt="Trysil - Delphi ORM" title="Trysil - Delphi ORM">
  </picture>
</p>

> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

## Define entity
<pre>
type

{ TPersonalData }

  [TSequence('PersonalDataID')]
  [TTable('PersonalData')]
  TPersonalData = class
  strict protected
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Firstname')]
    FFirstname: String;

    [TColumn('Lastname')]
    FLastname: String;

    [TColumn('Company')]
    FCompany: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property Company: String read FCompany write FCompany;
    property Email: String read FEmail write FEmail;
  end;
</pre>

---

Make With ❤ @davidlastrucci<br>
[https://www.lastrucci.net/](https://www.lastrucci.net)
