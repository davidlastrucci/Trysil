unit Trysil.Languages.FR;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts;

type

{ TTLanguageFR }

  TTLanguageFR = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageFR }

class procedure TTLanguageFR.Translate;
begin
  TTLanguage.Instance.Add(SNotValidEventClass, 'Constructeur non valide dans la classe TTEvent : %0:s.');
  TTLanguage.Instance.Add(SNotEventType, 'Type TTEvent non valide : %0:s.');
  TTLanguage.Instance.Add(SInvalidRttiObjectType, 'Le type TRttiObject n''est pas valide.');
  TTLanguage.Instance.Add(SDuplicateTableAttribute, 'Attribut TTable en double.');
  TTLanguage.Instance.Add(SDuplicateSequenceAttribute, 'Attribut TSequence en double.');
  TTLanguage.Instance.Add(SDuplicateWhereClauseAttribute, 'Attribut TWhereClause en double.');
  TTLanguage.Instance.Add(SDuplicatePrimaryKeyAttribute, 'Attribut TPrimaryKey en double.');
  TTLanguage.Instance.Add(SDuplicateVersionColumnAttribute, 'Attribut TVersionColumn en double.');
  TTLanguage.Instance.Add(SInsertEventAttribute, 'Attribut TInsertEventAttribute en double.');
  TTLanguage.Instance.Add(SUpdateEventAttribute, 'Attribut TUpdateEventAttribute en double.');
  TTLanguage.Instance.Add(SDeleteEventAttribute, 'Attribut TDeleteEventAttribute en double.');
  TTLanguage.Instance.Add(SNotDefinedPrimaryKey, 'Clé primaire : non définie.');
  TTLanguage.Instance.Add(SNotValidPrimaryKeyType, 'Clé primaire : type non valide.');
  TTLanguage.Instance.Add(SNotDefinedSequence, 'Séquence : non définie.');
  TTLanguage.Instance.Add(SReadOnly, '"Clé primaire" ou "Colonne de version" ne sont pas définies.');
  TTLanguage.Instance.Add(SReadOnlyPrimaryKey, '"Clé primaire" n''est pas définie.');
  TTLanguage.Instance.Add(SRequiredValidation, '%0:s ne peut pas être vide.');
  TTLanguage.Instance.Add(SNotInvalidTypeValidation, 'Type de %0:s non valide pour la validation.');
  TTLanguage.Instance.Add(SMaxLengthValidation, '%0:s ne peut pas dépasser %1:d caractères.');
  TTLanguage.Instance.Add(SMinLengthValidation, '%0:s ne peut pas être inférieur à %1:d caractères.');
  TTLanguage.Instance.Add(SMinValueValidation, '%0:s ne peut pas être inférieur à %1:s.');
  TTLanguage.Instance.Add(SMaxValueValidation, '%0:s ne peut pas dépasser %1:s.');
  TTLanguage.Instance.Add(SLessValidation, '%0:s doit être inférieur à %1:s.');
  TTLanguage.Instance.Add(SGreaterValidation, '%0:s doit être supérieur à %1:s.');
  TTLanguage.Instance.Add(SRangeValidation, '%0:s doit être compris entre %1:s et %2:s.');
  TTLanguage.Instance.Add(SRegexValidation, '%1:s n''est pas une valeur valide pour %0:s.');
  TTLanguage.Instance.Add(SEMailValidation, '%0:s : %1:s n''est pas une adresse e-mail valide.');
  TTLanguage.Instance.Add(SNotValidValidator, 'Méthode de validation non valide : méthode %0:s de l''entité %1:s.');
  TTLanguage.Instance.Add(SInvalidNullableType, 'Le type nullable n''est pas valide.');
  TTLanguage.Instance.Add(SPropertyIDNotFound, 'ID de propriété introuvable');
  TTLanguage.Instance.Add(STypeIsNotAList, 'Le type %0:s n''est pas une liste générique.');
  TTLanguage.Instance.Add(STypeHasNotValidConstructor, 'Le type %0:s n''a pas de constructeur valide.');
  TTLanguage.Instance.Add(SClonedEntity, 'Impossible d''insérer une entité clonée : "%0:s".');
  TTLanguage.Instance.Add(SNotValidEntity, 'Entité clonée non valide : "%0:s".');
  TTLanguage.Instance.Add(SDeletedEntity, 'L''entité clonée "%0:s" a été supprimée.');
  TTLanguage.Instance.Add(SSessionNotTwice, 'La session ne peut pas être utilisée deux fois.');
  TTLanguage.Instance.Add(SNullableTypeHasNoValue, 'Le type nullable n''a pas de valeur : opération non valide.');
  TTLanguage.Instance.Add(SCannotAssignPointerToNullable, 'Impossible d''assigner un pointeur non nul à un type nullable.');
  TTLanguage.Instance.Add(SDuplicateColumn, 'Définition de colonne en double : %0:s.');
  TTLanguage.Instance.Add(SColumnNotFound, 'Colonne %0:s introuvable.');
  TTLanguage.Instance.Add(SRelationError, '"%0:s" est actuellement utilisé, impossible de supprimer.');
  TTLanguage.Instance.Add(SColumnTypeError, 'Colonne non enregistrée pour le type %0:s.');
  TTLanguage.Instance.Add(SParameterTypeError, 'Paramètre non enregistré pour le type %0:s.');
  TTLanguage.Instance.Add(STableMapNotFound, 'TableMap pour la classe %0:s introuvable');
  TTLanguage.Instance.Add(SPrimaryKeyNotDefined, 'Clé primaire non définie pour la classe %0:s');
  TTLanguage.Instance.Add(SRecordChanged, 'Entité modifiée par un autre utilisateur.');
  TTLanguage.Instance.Add(SSyntaxError, 'Syntaxe incorrecte : trop d''enregistrements affectés.');
  TTLanguage.Instance.Add(STransactionNotSupported, 'La connexion ne supporte pas les transactions.');
  TTLanguage.Instance.Add(SInTransaction, '%0:s : transaction déjà démarrée.');
  TTLanguage.Instance.Add(SNotInTransaction, '%0:s : transaction pas encore démarrée.');
  TTLanguage.Instance.Add(SNotValidTransaction, 'La transaction n''est plus valide.');
  TTLanguage.Instance.Add(SNotValidConnectionDriver, 'Connexion introuvable pour le pilote "%s".');
  TTLanguage.Instance.Add(SNotValidConnection, 'Connexion introuvable "%s".');
end;

end.

