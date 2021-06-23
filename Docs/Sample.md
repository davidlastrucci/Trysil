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

## Simple sample

### Model
Using **Trysil** you can define a model that map a database table into a class.

<pre>
<b>type</b>

<i>{ TPerson }</i>

  [TTable('Persons')]
  [TSequence('PersonsID')]
  TPerson = <b>class</b>
  <b>strict private</b>
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Firstname')]
    FFirstname: <b>String</b>;

    [TColumn('Lastname')]
    FLastname: <b>String</b>;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;
  <b>public</b>
    property ID: TTPrimaryKey read FID;
    property Firstname: <b>String</b> read FFirstname write FFirstname;
    property Lastname: <b>String</b> read FLastname write FLastname;
  <b>end</b>;
</pre>


### Example
 Then you can use entities for CRUD operations

<pre>
<b>var</b>
  LConnection: TTConnection;
  LContext: TTContext;
  LPersons: TTList&lt;TPerson&gt;;
  LPredicate: TTPredicate&lt;TPerson&gt;;
  LPerson: TPerson;
<b>begin</b>
  TTSqlServerConnection.RegisterConnection(
    'Main', 'Server', 'DatabaseName');

  LConnection := TTSqlServerConnection.Create('Main');
  <b>try</b>
    LContext := TTContext.Create(LConnection);
    <b>try</b>
      LPersons := TTList&lt;TPerson&gt;.Create;
      <b>try</b>
        LContext.SelectAll&lt;TPerson&gt;(LPersons);

        LPredicate := <b>function</b>(<b>const</b> AItem: TPerson): Boolean
        begin
          result := AItem.Firstname.Equals('David');
        end;

        <b>for</b> LPerson <b>in</b> LPersons.Where(LPredicate) <b>do</b>
          Writeln(Format('%s %s', [LPerson.Firstname, LPerson.Lastname]));
      <b>finally</b>
        LPersons.Free;
      <b>end</b>;
    <b>finally</b>
      LContext.Free;
    <b>end</b>;
  <b>finally</b>
    LConnection.Free;
  <b>end</b>;
<b>end</b>;
</pre>

**Enjoy!**

---
<p>
  <a href="https://www.lastrucci.net/">
    <img width="400" height="100" src="https://www.lastrucci.net/images/badge.small.png" title="https://www.lastrucci.net/">
  </a>
</p>
