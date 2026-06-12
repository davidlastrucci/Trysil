(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.IdentityMap;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Generics.Collections,
  Trysil.Context,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractIdentityMapTests }

  TTAbstractIdentityMapTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure GetReturnsSameInstanceWhenCalledTwice;

    [Test]
    procedure SelectAllReusesIdentityMappedInstance;

    [Test]
    procedure IdentityMapIsScopedToContext;

    [Test]
    procedure WithoutIdentityMapGetReturnsDifferentInstances;

    [Test]
    procedure TwoUnsavedCreateEntityDoNotLeak;
  end;

implementation

{ TTAbstractIdentityMapTests }

procedure TTAbstractIdentityMapTests.GetReturnsSameInstanceWhenCalledTwice;
var
  LInserted: TTestCustomer;
  LFirst: TTestCustomer;
  LSecond: TTestCustomer;
begin
  LInserted := FContext.CreateEntity<TTestCustomer>();
  LInserted.Name := 'Cached';
  FContext.Insert<TTestCustomer>(LInserted);

  LFirst := FContext.Get<TTestCustomer>(LInserted.ID);
  LSecond := FContext.Get<TTestCustomer>(LInserted.ID);

  Assert.AreSame(LFirst, LSecond,
    'Identity map must return the same instance for repeated Get<T>');
end;

procedure TTAbstractIdentityMapTests.SelectAllReusesIdentityMappedInstance;
var
  LInserted: TTestCustomer;
  LLoaded: TTestCustomer;
  LList: TTList<TTestCustomer>;
begin
  LInserted := FContext.CreateEntity<TTestCustomer>();
  LInserted.Name := 'Shared';
  FContext.Insert<TTestCustomer>(LInserted);

  LLoaded := FContext.Get<TTestCustomer>(LInserted.ID);

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreSame(LLoaded, LList[0],
      'SelectAll must return identity-mapped instance');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractIdentityMapTests.IdentityMapIsScopedToContext;
var
  LInserted: TTestCustomer;
  LFromFirst: TTestCustomer;
  LSecondContext: TTContext;
  LFromSecond: TTestCustomer;
begin
  LInserted := FContext.CreateEntity<TTestCustomer>();
  LInserted.Name := 'Scoped';
  FContext.Insert<TTestCustomer>(LInserted);

  LFromFirst := FContext.Get<TTestCustomer>(LInserted.ID);

  LSecondContext := TTContext.Create(Connection);
  try
    LFromSecond := LSecondContext.Get<TTestCustomer>(LInserted.ID);
    Assert.AreNotSame(LFromFirst, LFromSecond,
      'Different contexts must yield different identity-map instances');
    Assert.AreEqual(LFromFirst.ID, LFromSecond.ID);
  finally
    LSecondContext.Free;
  end;
end;

procedure TTAbstractIdentityMapTests.TwoUnsavedCreateEntityDoNotLeak;
var
  LFirst: TTestCustomer;
  LSecond: TTestCustomer;
begin
  LFirst := FContext.CreateEntity<TTestCustomer>();
  Assert.IsNotNull(LFirst,
    'First CreateEntity must return an instance');

  LSecond := FContext.CreateEntity<TTestCustomer>();
  Assert.IsNotNull(LSecond,
    'Second CreateEntity must return an instance');
  Assert.IsTrue(LSecond.ID > 0,
    'Second created entity must have a valid primary key');
end;

procedure TTAbstractIdentityMapTests.WithoutIdentityMapGetReturnsDifferentInstances;
var
  LInserted: TTestCustomer;
  LContextNoMap: TTContext;
  LFirst: TTestCustomer;
  LSecond: TTestCustomer;
begin
  LInserted := FContext.CreateEntity<TTestCustomer>();
  LInserted.Name := 'NoCache';
  FContext.Insert<TTestCustomer>(LInserted);

  LContextNoMap := TTContext.Create(Connection, False);
  try
    Assert.IsFalse(LContextNoMap.UseIdentityMap,
      'Context must report identity map disabled');
    LFirst := LContextNoMap.Get<TTestCustomer>(LInserted.ID);
    try
      LSecond := LContextNoMap.Get<TTestCustomer>(LInserted.ID);
      try
        Assert.AreNotSame(LFirst, LSecond,
          'Without identity map, repeated Get<T> must return new instances');
        Assert.AreEqual(LFirst.ID, LSecond.ID);
      finally
        LSecond.Free;
      end;
    finally
      LFirst.Free;
    end;
  finally
    LContextNoMap.Free;
  end;
end;

end.
