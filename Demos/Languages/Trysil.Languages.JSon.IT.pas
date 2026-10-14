unit Trysil.Languages.JSon.IT;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,
  Trysil.JSon.Consts;

type

{ TTLanguageJSonIT }

  TTLanguageJSonIT = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageJSonIT }

class procedure TTLanguageJSonIT.Translate;
begin
  TTLanguage.Instance.Add(SDeserializerNotFound, 'Deserializzatore JSon non trovato per %s.');
  TTLanguage.Instance.Add(SSerializerReentered, 'EntityToJSon è stata rientrata %0:d volte senza tornare. Ogni chiamata apre una profondità e un insieme di visitati propri, quindi MaxLevels e la guardia sui cicli non attraversano una rientranza: due entità i cui eventi si serializzano a vicenda ricorrono finché lo stack non finisce. Serializza l''entità collegata fuori dall''evento.');
  TTLanguage.Instance.Add(SNoIdentityMap, 'TTJSonContext non può usare l''IdentityMap.');
  TTLanguage.Instance.Add(SNotAJSonArray, 'Il JSon non è un array.');
  TTLanguage.Instance.Add(SNotAJSonObjectInArray, 'L''elemento %d dell''array JSon non è un oggetto.');
  TTLanguage.Instance.Add(SNotAJSonObjectInList, 'L''elemento %0:d dell''array "%1:s" non è un oggetto.');
  TTLanguage.Instance.Add(SNotAJSonObject, 'Il JSon non è un oggetto.');
  TTLanguage.Instance.Add(SNotValidJSonArray, 'Il campo "%s" non è un array. Un corpo che il deserializzatore non sa leggere viene rifiutato, non ignorato.');
  TTLanguage.Instance.Add(SNotValidSqid, 'Il valore di "%s" non è uno sqid valido.');
  TTLanguage.Instance.Add(SNotValidJSon, 'Il JSon non è valido: %s');
  TTLanguage.Instance.Add(SNotValidJSonValue, 'Il valore di "%s" non è valido per il suo tipo.');
  TTLanguage.Instance.Add(SNotValidType, 'Tipo non valido');
  TTLanguage.Instance.Add(SSerializerNotFound, 'Serializzatore JSon non trovato per %s.');
  TTLanguage.Instance.Add(SSqidsAlphabetInUse, 'L''alfabeto Sqids non si può cambiare dopo che un id è stato codificato o decodificato: configuralo all''avvio.');
  TTLanguage.Instance.Add(SSqidsAlphabetNotLowerCase, 'L''alfabeto Sqids deve contenere solo caratteri ASCII che non siano lettere maiuscole: "%s" non lo è. Gli id vengono riletti in minuscolo.');
  TTLanguage.Instance.Add(SSqidsAlphabetNotUnique, 'L''alfabeto Sqids non deve ripetere un carattere: "%s" compare più di una volta.');
  TTLanguage.Instance.Add(SSqidsAlphabetTooShort, 'L''alfabeto Sqids deve essere lungo almeno %d caratteri.');
end;

end.
