(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Language;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Threading,
  DUnitX.TestFramework,

  Trysil.Consts,
  Trysil.Http.Consts;

type

{ TTHttpLanguageTests }

  [TestFixture]
  TTHttpLanguageTests = class
  strict private
    procedure SetHeader(const AValue: String);
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure ABrowserHeaderIsUnderstood;

    [Test]
    procedure TheRegionIsTriedBeforeTheLanguage;

    [Test]
    procedure QualityDecidesTheOrder;

    [Test]
    procedure AnUnknownLanguageFallsBackToTheKey;

    [Test]
    procedure OneThreadDoesNotSeeTheLanguageOfAnother;

    [Test]
    procedure AThreadThatSetNoLanguageFallsBackToTheKey;

    [Test]
    procedure AHeaderInUpperCaseFindsTheSameTranslation;
  end;

implementation

{ TTHttpLanguageTests }

procedure TTHttpLanguageTests.Setup;
begin
  TTHttpLanguage.Instance.Add('it', 'Hello', 'Ciao');
  TTHttpLanguage.Instance.Add('en', 'Hello', 'Hello');
  TTHttpLanguage.Instance.Add('it-CH', 'Hello', 'Ciao (CH)');
end;

procedure TTHttpLanguageTests.TearDown;
begin
  TTHttpLanguage.Instance.RemoveThreadLanguage;
end;

procedure TTHttpLanguageTests.SetHeader(const AValue: String);
begin
  TTHttpLanguage.Instance.SetThreadLanguage(AValue);
end;

procedure TTHttpLanguageTests.ABrowserHeaderIsUnderstood;
var
  LValue: String;
begin
  SetHeader('it-IT,it;q=0.9,en;q=0.8');

  Assert.IsTrue(
    TTHttpLanguage.Instance.TryTranslate('Hello', LValue),
    'The header was kept whole and compared against the registered key, ' +
    'so a real browser never matched anything and the translation simply ' +
    'never happened');
  Assert.AreEqual('Ciao', LValue);
end;

procedure TTHttpLanguageTests.TheRegionIsTriedBeforeTheLanguage;
var
  LValue: String;
begin
  SetHeader('it-CH,it;q=0.9');

  Assert.IsTrue(TTHttpLanguage.Instance.TryTranslate('Hello', LValue));
  Assert.AreEqual(
    'Ciao (CH)',
    LValue,
    'A regional tag is tried before the primary one, so a translation ' +
    'registered for it-CH wins over the generic it');
end;

procedure TTHttpLanguageTests.QualityDecidesTheOrder;
var
  LValue: String;
begin
  SetHeader('en;q=0.2,it;q=0.9');

  Assert.IsTrue(TTHttpLanguage.Instance.TryTranslate('Hello', LValue));
  Assert.AreEqual(
    'Ciao',
    LValue,
    'The order in the header is not the order of preference: q is');
end;

procedure TTHttpLanguageTests.AnUnknownLanguageFallsBackToTheKey;
var
  LValue: String;
begin
  SetHeader('de-DE,de;q=0.9');

  Assert.IsFalse(
    TTHttpLanguage.Instance.TryTranslate('Hello', LValue),
    'Nothing is registered for German, and the resolver says so instead ' +
    'of inventing a language');
end;

procedure TTHttpLanguageTests.OneThreadDoesNotSeeTheLanguageOfAnother;
var
  LTask: ITask;
  LOther: String;
begin
  TTHttpLanguage.Instance.Add('fr', 'Hello', 'Bonjour');
  TTHttpLanguage.Instance.Add('it', 'Hello', 'Ciao');
  SetHeader('it');

  LTask := TTask.Run(
    procedure
    begin
      TTHttpLanguage.Instance.SetThreadLanguage('fr');
      try
        LOther := TTLanguage.Instance.Translate('Hello');
      finally
        TTHttpLanguage.Instance.RemoveThreadLanguage;
      end;
    end);
  LTask.Wait;

  Assert.AreEqual(
    'Bonjour',
    LOther,
    'The other thread must be answered in its own language');
  Assert.AreEqual(
    'Ciao',
    TTLanguage.Instance.Translate('Hello'),
    'And this one must still be answered in its own: the language is per ' +
    'thread, and a request must never be translated with the language of ' +
    'the request being served next to it');
end;

procedure TTHttpLanguageTests.AThreadThatSetNoLanguageFallsBackToTheKey;
var
  LTask: ITask;
  LOther: String;
begin
  TTHttpLanguage.Instance.Add('it', 'Hello', 'Ciao');
  SetHeader('it');

  LTask := TTask.Run(
    procedure
    begin
      LOther := TTLanguage.Instance.Translate('Hello');
    end);
  LTask.Wait;

  Assert.AreEqual(
    'Hello',
    LOther,
    'A thread nobody set a language on has no language, and falls back to ' +
    'the key: it must not inherit the one another thread happens to hold');
end;

procedure TTHttpLanguageTests.AHeaderInUpperCaseFindsTheSameTranslation;
var
  LValue: String;
begin
  SetHeader('IT');

  Assert.IsTrue(
    TTHttpLanguage.Instance.TryTranslate('Hello', LValue),
    'The comparer behind the table calls two entries equal without regard ' +
    'to case, and the hash was taken on the case it was given: the two ' +
    'never met in one bucket, so the table was case sensitive in fact ' +
    'while its comparer said it was not');
  Assert.AreEqual('Ciao', LValue);
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpLanguageTests);

end.
