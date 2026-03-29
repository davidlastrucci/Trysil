(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Cases;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Rtti,
  System.JSon,
  Data.DB,

  Trysil.Types,
  Trysil.Filter,
  Trysil.Validation,
  Trysil.Validation.Attributes,
  Trysil.Generics.Collections,
  Trysil.Exceptions,
  Trysil.Attributes,
  Trysil.Mapping;

type

{ ============================================================================ }
{ Test entity — used by TTMapper fixture                                       }
{ ============================================================================ }

  [TTable('TestEntidade')]
  [TSequence('TestEntidadeSeq')]
  TTestEntidade = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(50)]
    [TColumn('Nome')]
    FNome: String;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID write FID;
    property Nome: String read FNome write FNome;
    property VersionID: TTVersion read FVersionID write FVersionID;
  end;

{ ============================================================================ }
{ Helper class — used by TTObjectList fixture                                  }
{ ============================================================================ }

  TIntObject = class
  public
    Value: Integer;
    constructor Create(const AValue: Integer);
  end;

{ ============================================================================ }
{ TTestNullable                                                                }
{ ============================================================================ }

  [TestFixture]
  TTestNullable = class
  public
    [Test] procedure DefaultInt_IsNull;
    [Test] procedure DefaultString_IsNull;
    [Test] procedure CreateIntWithValue_IsNotNull;
    [Test] procedure CreateStringWithValue_IsNotNull;
    [Test] procedure GetValue_ReturnsCorrectInt;
    [Test] procedure GetValue_ReturnsCorrectString;
    [Test] procedure GetValueOnNull_RaisesETException;
    [Test] procedure GetValueOrDefault_NotNull_ReturnsValue;
    [Test] procedure GetValueOrDefault_Null_ReturnsZero;
    [Test] procedure GetValueOrDefaultWithParam_Null_ReturnsParam;
    [Test] procedure Equals_BothNull_IsTrue;
    [Test] procedure Equals_NullAndValue_IsFalse;
    [Test] procedure Equals_SameValues_IsTrue;
    [Test] procedure Equals_DifferentValues_IsFalse;
    [Test] procedure ImplicitFromValue_IsNotNull;
    [Test] procedure ImplicitToValue_ReturnsCorrectValue;
    [Test] procedure ImplicitFromNilPointer_IsNull;
    [Test] procedure ImplicitFromNonNilPointer_RaisesException;
    [Test] procedure CopyConstructor_FromNull_IsNull;
    [Test] procedure CopyConstructor_FromValue_HasSameValue;
    [Test] procedure EqualOperator_BothNull_IsTrue;
    [Test] procedure NotEqualOperator_DifferentValues_IsTrue;
  end;

{ ============================================================================ }
{ TTestFilterPaging                                                            }
{ ============================================================================ }

  [TestFixture]
  TTestFilterPaging = class
  public
    [Test] procedure Empty_IsEmpty_True;
    [Test] procedure Empty_HasPagination_False;
    [Test] procedure ValidPaging_HasPagination_True;
    [Test] procedure ValidPaging_IsEmpty_False;
    [Test] procedure ZeroLimit_IsEmpty_True;
    [Test] procedure NegativeStart_IsEmpty_True;
    [Test] procedure Properties_SetCorrectly;
  end;

{ ============================================================================ }
{ TTestFilter                                                                  }
{ ============================================================================ }

  [TestFixture]
  TTestFilter = class
  public
    [Test] procedure Empty_IsEmpty_True;
    [Test] procedure EmptyWhere_IsEmpty_True;
    [Test] procedure WithWhere_IsEmpty_False;
    [Test] procedure CreateWithMaxRecord_HasPagination;
    [Test] procedure CreateWithStartAndLimit_HasPagination;
    [Test] procedure AddParameter_CountIncreases;
    [Test] procedure AddParameterWithSize_CountIncreases;
    [Test] procedure Where_IsSetCorrectly;
  end;

{ ============================================================================ }
{ TTestValidationErrors                                                        }
{ ============================================================================ }

  [TestFixture]
  TTestValidationErrors = class
  public
    [Test] procedure New_IsEmpty_True;
    [Test] procedure AfterAdd_IsEmpty_False;
    [Test] procedure ToString_ContainsColumnName;
    [Test] procedure ToString_ContainsMessage;
    [Test] procedure ToJson_IsValidArray;
    [Test] procedure ToJson_ContainsColumnName;
    [Test] procedure ToJson_ContainsErrorMessage;
    [Test] procedure MemoryLeak_CreateDestroy;
  end;

{ ============================================================================ }
{ TTestHashList                                                                }
{ ============================================================================ }

  [TestFixture]
  TTestHashList = class
  public
    [Test] procedure Add_NewItem_ReturnsTrue;
    [Test] procedure Add_DuplicateItem_ReturnsFalse;
    [Test] procedure Contains_AddedItem_IsTrue;
    [Test] procedure Contains_NotAddedItem_IsFalse;
    [Test] procedure Remove_ExistingItem_ReturnsTrue;
    [Test] procedure Remove_ExistingItem_ThenNotContains;
    [Test] procedure Remove_NonExistentItem_ReturnsFalse;
    [Test] procedure MemoryLeak_CreateDestroy;
  end;

{ ============================================================================ }
{ TTestObjectList                                                              }
{ ============================================================================ }

  [TestFixture]
  TTestObjectList = class
  public
    [Test] procedure Add_IncreasesCount;
    [Test] procedure OwnsObjects_True_FreesOnListFree;
    [Test] procedure OwnsObjects_False_DoesNotFreeObjects;
    [Test] procedure Clear_RemovesAll;
    [Test] procedure Where_FiltersByPredicate;
    [Test] procedure MemoryLeak_CreateDestroy;
  end;

{ ============================================================================ }
{ TTestExceptions                                                              }
{ ============================================================================ }

  [TestFixture]
  TTestExceptions = class
  public
    [Test] procedure ETException_MessageIsSet;
    [Test] procedure ETException_CreateFmt_FormatsMessage;
    [Test] procedure ETValidationException_InheritsFromETException;
    [Test] procedure ETConcurrentUpdate_InheritsFromETException;
    [Test] procedure ETDataIntegrity_InheritsFromETException;
    [Test] procedure ETException_NestedCapturedFromActiveException;
    [Test] procedure ETException_NullNestedWhenNoActiveException;
    [Test] procedure MemoryLeak_CreateDestroy;
  end;

{ ============================================================================ }
{ TTestMapper                                                                  }
{ ============================================================================ }

  [TestFixture]
  TTestMapper = class
  public
    [Test] procedure Load_ReturnsNotNil;
    [Test] procedure TableMap_Name_MatchesAttribute;
    [Test] procedure TableMap_SequenceName_MatchesAttribute;
    [Test] procedure TableMap_PrimaryKey_NotNil;
    [Test] procedure TableMap_PrimaryKey_NameCorrect;
    [Test] procedure TableMap_Columns_NotEmpty;
    [Test] procedure TableMap_VersionColumn_NotNil;
    [Test] procedure TableMap_VersionColumn_NameCorrect;
    [Test] procedure Load_SameType_ReturnsSameInstance;
  end;

{ ============================================================================ }
{ TTestValidationRequired                                                      }
{ ============================================================================ }

  [TestFixture]
  TTestValidationRequired = class
  public
    [Test] procedure EmptyString_AddsError;
    [Test] procedure NonEmptyString_NoError;
    [Test] procedure ZeroDateTime_AddsError;
    [Test] procedure CustomErrorMessage_IsUsed;
  end;

{ ============================================================================ }
{ TTestValidationLength                                                        }
{ ============================================================================ }

  [TestFixture]
  TTestValidationLength = class
  public
    [Test] procedure MaxLength_TooLong_AddsError;
    [Test] procedure MaxLength_Exact_NoError;
    [Test] procedure MaxLength_Shorter_NoError;
    [Test] procedure MinLength_TooShort_AddsError;
    [Test] procedure MinLength_Exact_NoError;
    [Test] procedure MinLength_Longer_NoError;
  end;

{ ============================================================================ }
{ TTestValidationValue                                                         }
{ ============================================================================ }

  [TestFixture]
  TTestValidationValue = class
  public
    [Test] procedure MinValue_Below_AddsError;
    [Test] procedure MinValue_AtMin_NoError;
    [Test] procedure MinValue_Above_NoError;
    [Test] procedure MaxValue_Above_AddsError;
    [Test] procedure MaxValue_AtMax_NoError;
    [Test] procedure MaxValue_Below_NoError;
    [Test] procedure Range_Below_AddsError;
    [Test] procedure Range_Above_AddsError;
    [Test] procedure Range_Within_NoError;
    [Test] procedure Range_AtMin_NoError;
    [Test] procedure Range_AtMax_NoError;
  end;

{ ============================================================================ }
{ TTestValidationRegex                                                         }
{ ============================================================================ }

  [TestFixture]
  TTestValidationRegex = class
  public
    [Test] procedure Regex_InvalidValue_AddsError;
    [Test] procedure Regex_ValidValue_NoError;
    [Test] procedure Regex_EmptyValue_NoError;
    [Test] procedure Email_InvalidEmail_AddsError;
    [Test] procedure Email_ValidEmail_NoError;
    [Test] procedure Email_EmptyValue_NoError;
  end;

implementation

{ ============================================================================ }
{ TIntObject                                                                   }
{ ============================================================================ }

constructor TIntObject.Create(const AValue: Integer);
begin
  inherited Create;
  Value := AValue;
end;

{ ============================================================================ }
{ TTestNullable                                                                }
{ ============================================================================ }

procedure TTestNullable.DefaultInt_IsNull;
var
  LValue: TTNullable<Integer>;
begin
  Assert.IsTrue(LValue.IsNull);
end;

procedure TTestNullable.DefaultString_IsNull;
var
  LValue: TTNullable<String>;
begin
  Assert.IsTrue(LValue.IsNull);
end;

procedure TTestNullable.CreateIntWithValue_IsNotNull;
var
  LValue: TTNullable<Integer>;
begin
  LValue := TTNullable<Integer>.Create(42);
  Assert.IsFalse(LValue.IsNull);
end;

procedure TTestNullable.CreateStringWithValue_IsNotNull;
var
  LValue: TTNullable<String>;
begin
  LValue := TTNullable<String>.Create('hello');
  Assert.IsFalse(LValue.IsNull);
end;

procedure TTestNullable.GetValue_ReturnsCorrectInt;
var
  LValue: TTNullable<Integer>;
begin
  LValue := TTNullable<Integer>.Create(99);
  Assert.AreEqual(99, LValue.Value);
end;

procedure TTestNullable.GetValue_ReturnsCorrectString;
var
  LValue: TTNullable<String>;
begin
  LValue := TTNullable<String>.Create('trysil');
  Assert.AreEqual('trysil', LValue.Value);
end;

procedure TTestNullable.GetValueOnNull_RaisesETException;
var
  LNullable: TTNullable<Integer>;
  LDummy: Integer;
begin
  Assert.WillRaise(
    procedure
    begin
      LDummy := LNullable.Value;
    end,
    ETException);
end;

procedure TTestNullable.GetValueOrDefault_NotNull_ReturnsValue;
var
  LValue: TTNullable<Integer>;
begin
  LValue := TTNullable<Integer>.Create(7);
  Assert.AreEqual(7, LValue.GetValueOrDefault);
end;

procedure TTestNullable.GetValueOrDefault_Null_ReturnsZero;
var
  LValue: TTNullable<Integer>;
begin
  Assert.AreEqual(0, LValue.GetValueOrDefault);
end;

procedure TTestNullable.GetValueOrDefaultWithParam_Null_ReturnsParam;
var
  LValue: TTNullable<Integer>;
begin
  Assert.AreEqual(42, LValue.GetValueOrDefault(42));
end;

procedure TTestNullable.Equals_BothNull_IsTrue;
var
  LValue1, LValue2: TTNullable<Integer>;
begin
  Assert.IsTrue(LValue1.Equals(LValue2));
end;

procedure TTestNullable.Equals_NullAndValue_IsFalse;
var
  LNull: TTNullable<Integer>;
  LValue: TTNullable<Integer>;
begin
  LValue := TTNullable<Integer>.Create(1);
  Assert.IsFalse(LNull.Equals(LValue));
end;

procedure TTestNullable.Equals_SameValues_IsTrue;
var
  LValue1, LValue2: TTNullable<Integer>;
begin
  LValue1 := TTNullable<Integer>.Create(10);
  LValue2 := TTNullable<Integer>.Create(10);
  Assert.IsTrue(LValue1.Equals(LValue2));
end;

procedure TTestNullable.Equals_DifferentValues_IsFalse;
var
  LValue1, LValue2: TTNullable<Integer>;
begin
  LValue1 := TTNullable<Integer>.Create(10);
  LValue2 := TTNullable<Integer>.Create(20);
  Assert.IsFalse(LValue1.Equals(LValue2));
end;

procedure TTestNullable.ImplicitFromValue_IsNotNull;
var
  LValue: TTNullable<Integer>;
begin
  LValue := 5;
  Assert.IsFalse(LValue.IsNull);
end;

procedure TTestNullable.ImplicitToValue_ReturnsCorrectValue;
var
  LNullable: TTNullable<Integer>;
  LInt: Integer;
begin
  LNullable := TTNullable<Integer>.Create(33);
  LInt := LNullable;
  Assert.AreEqual(33, LInt);
end;

procedure TTestNullable.ImplicitFromNilPointer_IsNull;
var
  LValue: TTNullable<Integer>;
begin
  LValue := nil;
  Assert.IsTrue(LValue.IsNull);
end;

procedure TTestNullable.ImplicitFromNonNilPointer_RaisesException;
var
  LDummy: Integer;
begin
  LDummy := 0;
  Assert.WillRaise(
    procedure
    var
      LValue: TTNullable<Integer>;
    begin
      LValue := Pointer(@LDummy);
    end,
    ETException);
end;

procedure TTestNullable.CopyConstructor_FromNull_IsNull;
var
  LNull: TTNullable<Integer>;
  LCopy: TTNullable<Integer>;
begin
  LCopy := TTNullable<Integer>.Create(LNull);
  Assert.IsTrue(LCopy.IsNull);
end;

procedure TTestNullable.CopyConstructor_FromValue_HasSameValue;
var
  LOriginal: TTNullable<Integer>;
  LCopy: TTNullable<Integer>;
begin
  LOriginal := TTNullable<Integer>.Create(55);
  LCopy := TTNullable<Integer>.Create(LOriginal);
  Assert.IsFalse(LCopy.IsNull);
  Assert.AreEqual(55, LCopy.Value);
end;

procedure TTestNullable.EqualOperator_BothNull_IsTrue;
var
  LValue1, LValue2: TTNullable<Integer>;
begin
  Assert.IsTrue(LValue1 = LValue2);
end;

procedure TTestNullable.NotEqualOperator_DifferentValues_IsTrue;
var
  LValue1, LValue2: TTNullable<Integer>;
begin
  LValue1 := TTNullable<Integer>.Create(1);
  LValue2 := TTNullable<Integer>.Create(2);
  Assert.IsTrue(LValue1 <> LValue2);
end;

{ ============================================================================ }
{ TTestFilterPaging                                                            }
{ ============================================================================ }

procedure TTestFilterPaging.Empty_IsEmpty_True;
var
  LPaging: TTFilterPaging;
begin
  LPaging := TTFilterPaging.Empty;
  Assert.IsTrue(LPaging.IsEmpty);
end;

procedure TTestFilterPaging.Empty_HasPagination_False;
var
  LPaging: TTFilterPaging;
begin
  LPaging := TTFilterPaging.Empty;
  Assert.IsFalse(LPaging.HasPagination);
end;

procedure TTestFilterPaging.ValidPaging_HasPagination_True;
var
  LPaging: TTFilterPaging;
begin
  LPaging := TTFilterPaging.Create(0, 10, 'Nome');
  Assert.IsTrue(LPaging.HasPagination);
end;

procedure TTestFilterPaging.ValidPaging_IsEmpty_False;
var
  LPaging: TTFilterPaging;
begin
  LPaging := TTFilterPaging.Create(0, 10, 'Nome');
  Assert.IsFalse(LPaging.IsEmpty);
end;

procedure TTestFilterPaging.ZeroLimit_IsEmpty_True;
var
  LPaging: TTFilterPaging;
begin
  LPaging := TTFilterPaging.Create(0, 0, 'Nome');
  Assert.IsTrue(LPaging.IsEmpty);
end;

procedure TTestFilterPaging.NegativeStart_IsEmpty_True;
var
  LPaging: TTFilterPaging;
begin
  LPaging := TTFilterPaging.Create(-1, 5, 'Nome');
  Assert.IsTrue(LPaging.IsEmpty);
end;

procedure TTestFilterPaging.Properties_SetCorrectly;
var
  LPaging: TTFilterPaging;
begin
  LPaging := TTFilterPaging.Create(5, 20, 'ID DESC');
  Assert.AreEqual(5, LPaging.Start);
  Assert.AreEqual(20, LPaging.Limit);
  Assert.AreEqual('ID DESC', LPaging.OrderBy);
end;

{ ============================================================================ }
{ TTestFilter                                                                  }
{ ============================================================================ }

procedure TTestFilter.Empty_IsEmpty_True;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Empty;
  Assert.IsTrue(LFilter.IsEmpty);
end;

procedure TTestFilter.EmptyWhere_IsEmpty_True;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('');
  Assert.IsTrue(LFilter.IsEmpty);
  Assert.AreEqual(0, Length(LFilter.Parameters));
end;

procedure TTestFilter.WithWhere_IsEmpty_False;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('ID = :p0');
  Assert.IsFalse(LFilter.IsEmpty);
end;

procedure TTestFilter.CreateWithMaxRecord_HasPagination;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('', 10, 'Nome');
  Assert.IsTrue(LFilter.Paging.HasPagination);
end;

procedure TTestFilter.CreateWithStartAndLimit_HasPagination;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('', 0, 10, 'ID');
  Assert.IsTrue(LFilter.Paging.HasPagination);
end;

procedure TTestFilter.AddParameter_CountIncreases;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('Nome = :p0');
  LFilter.AddParameter(':p0', TFieldType.ftWideString, TValue.From<String>('test'));
  Assert.AreEqual(1, Length(LFilter.Parameters));
end;

procedure TTestFilter.AddParameterWithSize_CountIncreases;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('Nome = :p0');
  LFilter.AddParameter(':p0', TFieldType.ftWideString, 50, TValue.From<String>('test'));
  Assert.AreEqual(1, Length(LFilter.Parameters));
end;

procedure TTestFilter.Where_IsSetCorrectly;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('ID > :p0');
  Assert.AreEqual('ID > :p0', LFilter.Where);
end;

{ ============================================================================ }
{ TTestValidationErrors                                                        }
{ ============================================================================ }

procedure TTestValidationErrors.New_IsEmpty_True;
var
  LErrors: TTValidationErrors;
begin
  LErrors := TTValidationErrors.Create;
  try
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
  end;
end;

procedure TTestValidationErrors.AfterAdd_IsEmpty_False;
var
  LErrors: TTValidationErrors;
begin
  LErrors := TTValidationErrors.Create;
  try
    LErrors.Add('FieldName', 'Error message');
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
  end;
end;

procedure TTestValidationErrors.ToString_ContainsColumnName;
var
  LErrors: TTValidationErrors;
begin
  LErrors := TTValidationErrors.Create;
  try
    LErrors.Add('MyColumn', 'Some error');
    Assert.IsTrue(LErrors.ToString.Contains('MyColumn'));
  finally
    LErrors.Free;
  end;
end;

procedure TTestValidationErrors.ToString_ContainsMessage;
var
  LErrors: TTValidationErrors;
begin
  LErrors := TTValidationErrors.Create;
  try
    LErrors.Add('MyColumn', 'Some error');
    Assert.IsTrue(LErrors.ToString.Contains('Some error'));
  finally
    LErrors.Free;
  end;
end;

procedure TTestValidationErrors.ToJson_IsValidArray;
var
  LErrors: TTValidationErrors;
  LJsonValue: TJSONValue;
begin
  LErrors := TTValidationErrors.Create;
  try
    LErrors.Add('Col', 'Msg');
    LJsonValue := TJSONObject.ParseJSONValue(LErrors.ToJSon);
    try
      Assert.IsNotNull(LJsonValue);
      Assert.IsTrue(LJsonValue is TJSONArray);
    finally
      LJsonValue.Free;
    end;
  finally
    LErrors.Free;
  end;
end;

procedure TTestValidationErrors.ToJson_ContainsColumnName;
var
  LErrors: TTValidationErrors;
begin
  LErrors := TTValidationErrors.Create;
  try
    LErrors.Add('MyColumn', 'Some error');
    Assert.IsTrue(LErrors.ToJSon.Contains('MyColumn'));
  finally
    LErrors.Free;
  end;
end;

procedure TTestValidationErrors.ToJson_ContainsErrorMessage;
var
  LErrors: TTValidationErrors;
begin
  LErrors := TTValidationErrors.Create;
  try
    LErrors.Add('MyColumn', 'Some error');
    Assert.IsTrue(LErrors.ToJSon.Contains('Some error'));
  finally
    LErrors.Free;
  end;
end;

procedure TTestValidationErrors.MemoryLeak_CreateDestroy;
var
  LErrors: TTValidationErrors;
begin
  LErrors := TTValidationErrors.Create;
  LErrors.Add('Col1', 'Error 1');
  LErrors.Add('Col2', 'Error 2');
  LErrors.Free;
  Assert.Pass;
end;

{ ============================================================================ }
{ TTestHashList                                                                }
{ ============================================================================ }

procedure TTestHashList.Add_NewItem_ReturnsTrue;
var
  LList: TTHashList<Integer>;
begin
  LList := TTHashList<Integer>.Create;
  try
    Assert.IsTrue(LList.Add(1));
  finally
    LList.Free;
  end;
end;

procedure TTestHashList.Add_DuplicateItem_ReturnsFalse;
var
  LList: TTHashList<Integer>;
begin
  LList := TTHashList<Integer>.Create;
  try
    LList.Add(1);
    Assert.IsFalse(LList.Add(1));
  finally
    LList.Free;
  end;
end;

procedure TTestHashList.Contains_AddedItem_IsTrue;
var
  LList: TTHashList<Integer>;
begin
  LList := TTHashList<Integer>.Create;
  try
    LList.Add(42);
    Assert.IsTrue(LList.Contains(42));
  finally
    LList.Free;
  end;
end;

procedure TTestHashList.Contains_NotAddedItem_IsFalse;
var
  LList: TTHashList<Integer>;
begin
  LList := TTHashList<Integer>.Create;
  try
    Assert.IsFalse(LList.Contains(99));
  finally
    LList.Free;
  end;
end;

procedure TTestHashList.Remove_ExistingItem_ReturnsTrue;
var
  LList: TTHashList<Integer>;
begin
  LList := TTHashList<Integer>.Create;
  try
    LList.Add(5);
    Assert.IsTrue(LList.Remove(5));
  finally
    LList.Free;
  end;
end;

procedure TTestHashList.Remove_ExistingItem_ThenNotContains;
var
  LList: TTHashList<Integer>;
begin
  LList := TTHashList<Integer>.Create;
  try
    LList.Add(5);
    LList.Remove(5);
    Assert.IsFalse(LList.Contains(5));
  finally
    LList.Free;
  end;
end;

procedure TTestHashList.Remove_NonExistentItem_ReturnsFalse;
var
  LList: TTHashList<Integer>;
begin
  LList := TTHashList<Integer>.Create;
  try
    Assert.IsFalse(LList.Remove(999));
  finally
    LList.Free;
  end;
end;

procedure TTestHashList.MemoryLeak_CreateDestroy;
var
  LList: TTHashList<String>;
begin
  LList := TTHashList<String>.Create;
  LList.Add('alpha');
  LList.Add('beta');
  LList.Add('gamma');
  LList.Free;
  Assert.Pass;
end;

{ ============================================================================ }
{ TTestObjectList                                                              }
{ ============================================================================ }

procedure TTestObjectList.Add_IncreasesCount;
var
  LList: TTObjectList<TIntObject>;
begin
  LList := TTObjectList<TIntObject>.Create(True);
  try
    LList.Add(TIntObject.Create(1));
    LList.Add(TIntObject.Create(2));
    Assert.AreEqual(2, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTestObjectList.OwnsObjects_True_FreesOnListFree;
var
  LList: TTObjectList<TIntObject>;
begin
  // FastMM4 will report a leak if OwnsObjects=True does not free items
  LList := TTObjectList<TIntObject>.Create(True);
  LList.Add(TIntObject.Create(10));
  LList.Add(TIntObject.Create(20));
  LList.Free;
  Assert.Pass;
end;

procedure TTestObjectList.OwnsObjects_False_DoesNotFreeObjects;
var
  LList: TTObjectList<TIntObject>;
  LObj: TIntObject;
begin
  LObj := TIntObject.Create(99);
  try
    LList := TTObjectList<TIntObject>.Create(False);
    try
      LList.Add(LObj);
      LList.Delete(0); // Remove reference without freeing the object
    finally
      LList.Free;
    end;
    Assert.AreEqual(99, LObj.Value); // Object must still be alive
  finally
    LObj.Free;
  end;
end;

procedure TTestObjectList.Clear_RemovesAll;
var
  LList: TTObjectList<TIntObject>;
begin
  LList := TTObjectList<TIntObject>.Create(True);
  try
    LList.Add(TIntObject.Create(1));
    LList.Add(TIntObject.Create(2));
    LList.Clear;
    Assert.AreEqual(0, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTestObjectList.Where_FiltersByPredicate;
var
  LList: TTObjectList<TIntObject>;
  LEnumerable: ITEnumerable<TIntObject>;
  LEnumerator: ITEnumerator<TIntObject>;
  LCount: Integer;
begin
  LList := TTObjectList<TIntObject>.Create(True);
  try
    LList.Add(TIntObject.Create(1));
    LList.Add(TIntObject.Create(2));
    LList.Add(TIntObject.Create(3));
    LList.Add(TIntObject.Create(4));

    LEnumerable := LList.Where(
      function(const AItem: TIntObject): Boolean
      begin
        Result := AItem.Value > 2;
      end);

    LCount := 0;
    LEnumerator := LEnumerable.GetEnumerator;
    while LEnumerator.MoveNext do
      Inc(LCount);

    Assert.AreEqual(2, LCount); // Items with Value 3 and 4
  finally
    LList.Free;
  end;
end;

procedure TTestObjectList.MemoryLeak_CreateDestroy;
var
  LList: TTObjectList<TIntObject>;
begin
  LList := TTObjectList<TIntObject>.Create(True);
  LList.Add(TIntObject.Create(1));
  LList.Add(TIntObject.Create(2));
  LList.Add(TIntObject.Create(3));
  LList.Free;
  Assert.Pass;
end;

{ ============================================================================ }
{ TTestExceptions                                                              }
{ ============================================================================ }

procedure TTestExceptions.ETException_MessageIsSet;
var
  LException: ETException;
begin
  LException := ETException.Create('test error');
  try
    Assert.AreEqual('test error', LException.Message);
  finally
    LException.Free;
  end;
end;

procedure TTestExceptions.ETException_CreateFmt_FormatsMessage;
var
  LException: ETException;
begin
  LException := ETException.CreateFmt('Error %d: %s', [42, 'test']);
  try
    Assert.AreEqual('Error 42: test', LException.Message);
  finally
    LException.Free;
  end;
end;

procedure TTestExceptions.ETValidationException_InheritsFromETException;
begin
  Assert.WillRaise(
    procedure
    begin
      raise ETValidationException.Create('validation error');
    end,
    ETValidationException);
end;

procedure TTestExceptions.ETConcurrentUpdate_InheritsFromETException;
begin
  Assert.WillRaise(
    procedure
    begin
      raise ETConcurrentUpdateException.Create('concurrent update');
    end,
    ETConcurrentUpdateException);
end;

procedure TTestExceptions.ETDataIntegrity_InheritsFromETException;
begin
  Assert.WillRaise(
    procedure
    begin
      raise ETDataIntegrityException.Create('data integrity');
    end,
    ETDataIntegrityException);
end;

procedure TTestExceptions.ETException_NestedCapturedFromActiveException;
var
  LException: ETException;
begin
  LException := nil;
  try
    try
      raise Exception.Create('inner error');
    except
      LException := ETException.Create('outer');
    end;
    Assert.IsNotNull(LException.NestedException);
    Assert.AreEqual('inner error', LException.NestedException.Message);
  finally
    LException.Free;
  end;
end;

procedure TTestExceptions.ETException_NullNestedWhenNoActiveException;
var
  LException: ETException;
begin
  LException := ETException.Create('standalone');
  try
    Assert.IsNull(LException.NestedException);
  finally
    LException.Free;
  end;
end;

procedure TTestExceptions.MemoryLeak_CreateDestroy;
var
  LException: ETException;
begin
  LException := ETException.Create('leak test');
  LException.Free;
  Assert.Pass;
end;

{ ============================================================================ }
{ TTestMapper                                                                  }
{ ============================================================================ }

procedure TTestMapper.Load_ReturnsNotNil;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.IsNotNull(LMap);
end;

procedure TTestMapper.TableMap_Name_MatchesAttribute;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.AreEqual('TestEntidade', LMap.Name);
end;

procedure TTestMapper.TableMap_SequenceName_MatchesAttribute;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.AreEqual('TestEntidadeSeq', LMap.SequenceName);
end;

procedure TTestMapper.TableMap_PrimaryKey_NotNil;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.IsNotNull(LMap.PrimaryKey);
end;

procedure TTestMapper.TableMap_PrimaryKey_NameCorrect;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.AreEqual('ID', LMap.PrimaryKey.Name);
end;

procedure TTestMapper.TableMap_Columns_NotEmpty;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.IsFalse(LMap.Columns.Empty);
end;

procedure TTestMapper.TableMap_VersionColumn_NotNil;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.IsNotNull(LMap.VersionColumn);
end;

procedure TTestMapper.TableMap_VersionColumn_NameCorrect;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestEntidade>;
  Assert.AreEqual('VersionID', LMap.VersionColumn.Name);
end;

procedure TTestMapper.Load_SameType_ReturnsSameInstance;
var
  LMap1, LMap2: TTTableMap;
begin
  LMap1 := TTMapper.Instance.Load<TTestEntidade>;
  LMap2 := TTMapper.Instance.Load<TTestEntidade>;
  Assert.AreSame(LMap1, LMap2);
end;

{ ============================================================================ }
{ TTestValidationRequired                                                      }
{ ============================================================================ }

procedure TTestValidationRequired.EmptyString_AddsError;
var
  LAttr: TRequiredAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRequiredAttribute.Create;
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Name', TValue.From<String>(''), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRequired.NonEmptyString_NoError;
var
  LAttr: TRequiredAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRequiredAttribute.Create;
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Name', TValue.From<String>('John'), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRequired.ZeroDateTime_AddsError;
var
  LAttr: TRequiredAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRequiredAttribute.Create;
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Date', TValue.From<TDateTime>(0), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRequired.CustomErrorMessage_IsUsed;
var
  LAttr: TRequiredAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRequiredAttribute.Create('Custom error');
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Name', TValue.From<String>(''), LErrors);
    Assert.IsTrue(LErrors.ToString.Contains('Custom error'));
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

{ ============================================================================ }
{ TTestValidationLength                                                        }
{ ============================================================================ }

procedure TTestValidationLength.MaxLength_TooLong_AddsError;
var
  LAttr: TMaxLengthAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMaxLengthAttribute.Create(5);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Col', TValue.From<String>('toolongstring'), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationLength.MaxLength_Exact_NoError;
var
  LAttr: TMaxLengthAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMaxLengthAttribute.Create(5);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Col', TValue.From<String>('hello'), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationLength.MaxLength_Shorter_NoError;
var
  LAttr: TMaxLengthAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMaxLengthAttribute.Create(10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Col', TValue.From<String>('hi'), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationLength.MinLength_TooShort_AddsError;
var
  LAttr: TMinLengthAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMinLengthAttribute.Create(5);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Col', TValue.From<String>('hi'), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationLength.MinLength_Exact_NoError;
var
  LAttr: TMinLengthAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMinLengthAttribute.Create(5);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Col', TValue.From<String>('hello'), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationLength.MinLength_Longer_NoError;
var
  LAttr: TMinLengthAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMinLengthAttribute.Create(3);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Col', TValue.From<String>('longer string'), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

{ ============================================================================ }
{ TTestValidationValue                                                         }
{ ============================================================================ }

procedure TTestValidationValue.MinValue_Below_AddsError;
var
  LAttr: TMinValueAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMinValueAttribute.Create(10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Age', TValue.From<Integer>(5), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.MinValue_AtMin_NoError;
var
  LAttr: TMinValueAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMinValueAttribute.Create(10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Age', TValue.From<Integer>(10), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.MinValue_Above_NoError;
var
  LAttr: TMinValueAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMinValueAttribute.Create(10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Age', TValue.From<Integer>(20), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.MaxValue_Above_AddsError;
var
  LAttr: TMaxValueAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMaxValueAttribute.Create(100);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Score', TValue.From<Integer>(150), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.MaxValue_AtMax_NoError;
var
  LAttr: TMaxValueAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMaxValueAttribute.Create(100);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Score', TValue.From<Integer>(100), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.MaxValue_Below_NoError;
var
  LAttr: TMaxValueAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TMaxValueAttribute.Create(100);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Score', TValue.From<Integer>(50), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.Range_Below_AddsError;
var
  LAttr: TRangeAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRangeAttribute.Create(1, 10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Count', TValue.From<Integer>(0), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.Range_Above_AddsError;
var
  LAttr: TRangeAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRangeAttribute.Create(1, 10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Count', TValue.From<Integer>(11), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.Range_Within_NoError;
var
  LAttr: TRangeAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRangeAttribute.Create(1, 10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Count', TValue.From<Integer>(5), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.Range_AtMin_NoError;
var
  LAttr: TRangeAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRangeAttribute.Create(1, 10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Count', TValue.From<Integer>(1), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationValue.Range_AtMax_NoError;
var
  LAttr: TRangeAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRangeAttribute.Create(1, 10);
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Count', TValue.From<Integer>(10), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

{ ============================================================================ }
{ TTestValidationRegex                                                         }
{ ============================================================================ }

procedure TTestValidationRegex.Regex_InvalidValue_AddsError;
var
  LAttr: TRegexAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRegexAttribute.Create('^\d+$');
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Code', TValue.From<String>('abc123'), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRegex.Regex_ValidValue_NoError;
var
  LAttr: TRegexAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TRegexAttribute.Create('^\d+$');
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Code', TValue.From<String>('12345'), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRegex.Regex_EmptyValue_NoError;
var
  LAttr: TRegexAttribute;
  LErrors: TTValidationErrors;
begin
  // Empty string bypasses regex check (TRequired handles empty)
  LAttr := TRegexAttribute.Create('^\d+$');
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Code', TValue.From<String>(''), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRegex.Email_InvalidEmail_AddsError;
var
  LAttr: TEMailAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TEMailAttribute.Create;
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Email', TValue.From<String>('notanemail'), LErrors);
    Assert.IsFalse(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRegex.Email_ValidEmail_NoError;
var
  LAttr: TEMailAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TEMailAttribute.Create;
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Email', TValue.From<String>('user@example.com'), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

procedure TTestValidationRegex.Email_EmptyValue_NoError;
var
  LAttr: TEMailAttribute;
  LErrors: TTValidationErrors;
begin
  LAttr := TEMailAttribute.Create;
  LErrors := TTValidationErrors.Create;
  try
    LAttr.Validate('Email', TValue.From<String>(''), LErrors);
    Assert.IsTrue(LErrors.IsEmpty);
  finally
    LErrors.Free;
    LAttr.Free;
  end;
end;

end.
