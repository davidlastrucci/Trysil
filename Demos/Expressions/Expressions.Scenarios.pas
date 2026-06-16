(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Expressions.Scenarios;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Context,
  Trysil.Filter,
  Trysil.Filter.Expression,
  Trysil.Generics.Collections,
  
  Expressions.Model;

type

{ TDemoScenarios }

  TDemoScenarios = class
  strict private
    FContext: TTContext;

    procedure Title(const AText: String);
    procedure RunFilter(const ADescription: String; const AFilter: TTFilter);

    procedure ShowAll;
    procedure SimpleComparison;
    procedure GroupingProblem;
    procedure BetweenInValuesLikeNull;
    procedure NotAndNesting;
    procedure OrderingWithProperties;
  public
    constructor Create(const AContext: TTContext);

    procedure Run;
  end;

implementation

{ TDemoScenarios }

constructor TDemoScenarios.Create(const AContext: TTContext);
begin
  inherited Create;
  FContext := AContext;
end;

procedure TDemoScenarios.Title(const AText: String);
begin
  Writeln;
  Writeln('========================================================');
  Writeln(AText);
  Writeln('========================================================');
end;

procedure TDemoScenarios.RunFilter(
  const ADescription: String; const AFilter: TTFilter);
var
  LList: TTList<TPerson>;
  LPerson: TPerson;
begin
  Writeln(ADescription);
  Writeln(Format('  WHERE: %s', [AFilter.Where]));
  LList := TTList<TPerson>.Create;
  try
    FContext.Select<TPerson>(LList, AFilter);
    for LPerson in LList do
      Writeln(Format('    %s', [LPerson.ToString]));
    Writeln(Format('  -> %d rows', [LList.Count]));
  finally
    LList.Free;
  end;
  Writeln;
end;

procedure TDemoScenarios.ShowAll;
var
  LList: TTList<TPerson>;
  LPerson: TPerson;
begin
  Title('Seed data (all People)');
  LList := TTList<TPerson>.Create;
  try
    FContext.SelectAll<TPerson>(LList);
    for LPerson in LList do
      Writeln(Format('    %s', [LPerson.ToString]));
  finally
    LList.Free;
  end;
end;

procedure TDemoScenarios.SimpleComparison;
var
  LProperties: TPersonProperties;
  LBuilder: TTFilterBuilder<TPerson>;
  LFilter: TTFilter;
begin
  Title('1. Simple parametric comparison');
  LProperties := TPersonProperties.Create;
  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder.Where(LProperties.Age >= 18).Build;
  finally
    LBuilder.Free;
  end;
  RunFilter('Adults (Age >= 18)', LFilter);
end;

procedure TDemoScenarios.GroupingProblem;
var
  LProperties: TPersonProperties;
  LBuilder: TTFilterBuilder<TPerson>;
  LFilter: TTFilter;
begin
  Title('2. (A or B) and C - the grouping that the flat chain gets wrong');

  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder
      .Where('City').Equal('Roma')
      .OrWhere('City').Equal('Milano')
      .AndWhere('Age').GreaterOrEqual(30)
      .Build;
  finally
    LBuilder.Free;
  end;
  RunFilter(
    'Fluent chain - WRONG: AND binds tighter, so it reads as ' +
    'Roma OR (Milano AND Age>=30)', LFilter);

  LProperties := TPersonProperties.Create;
  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder.Where(
      ((LProperties.City = 'Roma') or (LProperties.City = 'Milano')) and
      (LProperties.Age >= 30)).Build;
  finally
    LBuilder.Free;
  end;
  RunFilter(
    'Expression - CORRECT: explicit parentheses around the OR', LFilter);
end;

procedure TDemoScenarios.BetweenInValuesLikeNull;
var
  LProperties: TPersonProperties;
  LBuilder: TTFilterBuilder<TPerson>;
  LFilter: TTFilter;
begin
  Title('3. Between / InValues / Like / IsNull');
  LProperties := TPersonProperties.Create;

  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder.Where(
      LProperties.Salary.Between(1500.0, 2500.0)).Build;
  finally
    LBuilder.Free;
  end;
  RunFilter('Salary between 1500 and 2500', LFilter);

  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder.Where(
      LProperties.City.InValues(['Roma', 'Napoli'])).Build;
  finally
    LBuilder.Free;
  end;
  RunFilter('City in (Roma, Napoli)', LFilter);

  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder.Where(LProperties.LastName.Like('R%')).Build;
  finally
    LBuilder.Free;
  end;
  RunFilter('LastName like ''R%''', LFilter);

  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder.Where(LProperties.Department.IsNull).Build;
  finally
    LBuilder.Free;
  end;
  RunFilter('Department IS NULL', LFilter);
end;

procedure TDemoScenarios.NotAndNesting;
var
  LProperties: TPersonProperties;
  LBuilder: TTFilterBuilder<TPerson>;
  LFilter: TTFilter;
begin
  Title('4. not (...) and nested expressions');
  LProperties := TPersonProperties.Create;
  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder.Where(
      not ((LProperties.City = 'Roma') or
        (LProperties.City = 'Milano'))).Build;
  finally
    LBuilder.Free;
  end;
  RunFilter('People NOT in Roma or Milano', LFilter);
end;

procedure TDemoScenarios.OrderingWithProperties;
var
  LProperties: TPersonProperties;
  LBuilder: TTFilterBuilder<TPerson>;
  LFilter: TTFilter;
begin
  Title('5. Ordering with a TTProperty (type-safe column name)');
  LProperties := TPersonProperties.Create;
  LBuilder := FContext.CreateFilterBuilder<TPerson>;
  try
    LFilter := LBuilder
      .Where(LProperties.Age >= 18)
      .OrderByDesc(LProperties.Salary)
      .Build;
  finally
    LBuilder.Free;
  end;
  RunFilter('Adults ordered by Salary descending', LFilter);
end;

procedure TDemoScenarios.Run;
begin
  ShowAll;
  SimpleComparison;
  GroupingProblem;
  BetweenInValuesLikeNull;
  NotAndNesting;
  OrderingWithProperties;
end;

end.
