unit Trysil.Languages.JSon.FR;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,
  Trysil.JSon.Consts;

type

{ TTLanguageJSonFR }

  TTLanguageJSonFR = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageJSonFR }

class procedure TTLanguageJSonFR.Translate;
begin
  TTLanguage.Instance.Add(SDeserializerNotFound, 'Désérialiseur JSon introuvable pour %s.');
  TTLanguage.Instance.Add(SSerializerReentered, 'EntityToJSon a été réentrée %0:d fois sans retourner. Chaque appel ouvre sa propre profondeur et son propre ensemble de visités, donc MaxLevels et la garde de cycle ne franchissent pas une réentrance : deux entités dont les événements se sérialisent mutuellement récurrent jusqu''à épuisement de la pile. Sérialisez l''entité liée en dehors de l''événement.');
  TTLanguage.Instance.Add(SNoIdentityMap, 'TTJSonContext ne peut pas utiliser l''IdentityMap.');
  TTLanguage.Instance.Add(SNotAJSonArray, 'Le JSon n''est pas un tableau.');
  TTLanguage.Instance.Add(SNotAJSonObjectInArray, 'L''élément %d du tableau JSon n''est pas un objet.');
  TTLanguage.Instance.Add(SNotAJSonObjectInList, 'L''élément %0:d du tableau "%1:s" n''est pas un objet.');
  TTLanguage.Instance.Add(SNotAJSonObject, 'Le JSon n''est pas un objet.');
  TTLanguage.Instance.Add(SNotValidJSonArray, 'Le champ "%s" n''est pas un tableau. Un corps que le désérialiseur ne sait pas lire est refusé, non ignoré.');
  TTLanguage.Instance.Add(SNotValidSqid, 'La valeur de "%s" n''est pas un sqid valide.');
  TTLanguage.Instance.Add(SNotValidJSon, 'Le JSon n''est pas valide : %s');
  TTLanguage.Instance.Add(SNotValidJSonValue, 'La valeur de "%s" n''est pas valide pour son type.');
  TTLanguage.Instance.Add(SNotValidType, 'Type non valide');
  TTLanguage.Instance.Add(SSerializerNotFound, 'Sérialiseur JSon introuvable pour %s.');
  TTLanguage.Instance.Add(SSqidsAlphabetInUse, 'L''alphabet Sqids ne peut plus changer une fois qu''un id a été encodé ou décodé : configurez-le au démarrage.');
  TTLanguage.Instance.Add(SSqidsAlphabetNotLowerCase, 'L''alphabet Sqids ne doit contenir que des caractères ASCII qui ne sont pas des majuscules : "%s" n''en est pas un. Les id sont relus en minuscules.');
  TTLanguage.Instance.Add(SSqidsAlphabetNotUnique, 'L''alphabet Sqids ne doit pas répéter un caractère : "%s" apparaît plus d''une fois.');
  TTLanguage.Instance.Add(SSqidsAlphabetTooShort, 'L''alphabet Sqids doit faire au moins %d caractères.');
end;

end.
