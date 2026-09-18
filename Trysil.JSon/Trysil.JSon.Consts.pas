(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Consts;

interface

uses
  System.SysUtils,
  System.Classes;

resourcestring
  SNoIdentityMap = 'TTJSonContext can not use IdentityMap.';
  SNotAJSonObject = 'JSon is not an object.';
  SNotAJSonArray = 'JSon is not an array.';
  SNotAJSonObjectInArray = 'Item %d of the JSon array is not an object.';
  SNotAJSonObjectInList =
    'Item %0:d of the array "%1:s" is not an object.';
  SSerializerNotFound = 'JSon Serializer not found for %s.';
  SDeserializerNotFound = 'JSon Deserializer not found for %s.';
  SSqidsAlphabetTooShort = 'Sqids alphabet must be at least %d ' +
    'characters long.';
  SSqidsAlphabetNotLowerCase = 'Sqids alphabet must hold only ASCII ' +
    'characters that are not capital letters: "%s" is not one. Ids are ' +
    'read back in lower case.';
  SSqidsAlphabetNotUnique = 'Sqids alphabet must not repeat a character: ' +
    '"%s" appears more than once.';
  SSqidsAlphabetInUse = 'The Sqids alphabet cannot be changed once an id ' +
    'has been encoded or decoded: configure it at startup.';
  SNotValidSqid = 'Value of "%s" is not a valid sqid.';
  SNotValidType = 'Not valid type';
  SNotValidJSonArray = 'Field "%s" is not an array. A body the ' +
    'deserializer cannot read is refused, not ignored.';
  SNotValidJSon = 'The JSon is not valid: %s';
  SNotValidJSonValue = 'Value of "%s" is not valid for its type.';
  SSerializerReentered = 'EntityToJSon has been re-entered %0:d times ' +
    'without returning. Each call starts a depth and a visited set of its ' +
    'own, so MaxLevels and the cycle guard do not reach across one: two ' +
    'entities whose events serialize each other recur until the stack ' +
    'gives out. Serialize the related entity outside the event.';

implementation

end.
