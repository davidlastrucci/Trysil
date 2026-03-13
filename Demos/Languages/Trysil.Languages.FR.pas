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
  TTLanguage.Instance.Add(SNotDefinedPrimaryKey, 'Cl� primaire : non d�finie.');
  TTLanguage.Instance.Add(SNotValidPrimaryKeyType, 'Cl� primaire : type non valide.');
  TTLanguage.Instance.Add(SNotDefinedSequence, 'S�quence : non d�finie.');
  TTLanguage.Instance.Add(SReadOnly, '"Cl� primaire" et "Colonne de version" doivent �tre toutes les deux d�finies.');
  TTLanguage.Instance.Add(SReadOnlyPrimaryKey, '"Cl� primaire" n''est pas d�finie.');
  TTLanguage.Instance.Add(SRequiredValidation, '%0:s ne peut pas �tre vide.');
  TTLanguage.Instance.Add(SNotInvalidTypeValidation, 'Type de %0:s non valide pour la validation.');
  TTLanguage.Instance.Add(SMaxLengthValidation, '%0:s ne peut pas d�passer %1:d caract�res.');
  TTLanguage.Instance.Add(SMinLengthValidation, '%0:s ne peut pas �tre inf�rieur � %1:d caract�res.');
  TTLanguage.Instance.Add(SMinValueValidation, '%0:s ne peut pas �tre inf�rieur � %1:s.');
  TTLanguage.Instance.Add(SMaxValueValidation, '%0:s ne peut pas d�passer %1:s.');
  TTLanguage.Instance.Add(SLessValidation, '%0:s doit �tre inf�rieur � %1:s.');
  TTLanguage.Instance.Add(SGreaterValidation, '%0:s doit �tre sup�rieur � %1:s.');
  TTLanguage.Instance.Add(SRangeValidation, '%0:s doit �tre compris entre %1:s et %2:s.');
  TTLanguage.Instance.Add(SRegexValidation, '%1:s n''est pas une valeur valide pour %0:s.');
  TTLanguage.Instance.Add(SEMailValidation, '%0:s : %1:s n''est pas une adresse e-mail valide.');
  TTLanguage.Instance.Add(SNotValidValidator, 'M�thode de validation non valide : m�thode %0:s de l''entit� %1:s.');
  TTLanguage.Instance.Add(SInvalidNullableType, 'Le type nullable n''est pas valide.');
  TTLanguage.Instance.Add(SPropertyIDNotFound, 'ID de propri�t� introuvable');
  TTLanguage.Instance.Add(STypeIsNotAList, 'Le type %0:s n''est pas une liste g�n�rique.');
  TTLanguage.Instance.Add(STypeHasNotValidConstructor, 'Le type %0:s n''a pas de constructeur valide.');
  TTLanguage.Instance.Add(SClonedEntity, 'Impossible d''ins�rer une entit� clon�e : "%0:s".');
  TTLanguage.Instance.Add(SNotValidEntity, 'Entit� clon�e non valide : "%0:s".');
  TTLanguage.Instance.Add(SDeletedEntity, 'L''entit� clon�e "%0:s" a �t� supprim�e.');
  TTLanguage.Instance.Add(SSessionNotTwice, 'La session ne peut pas �tre utilis�e deux fois.');
  TTLanguage.Instance.Add(SNullableTypeHasNoValue, 'Le type nullable n''a pas de valeur : op�ration non valide.');
  TTLanguage.Instance.Add(SCannotAssignPointerToNullable, 'Impossible d''assigner un pointeur non nul � un type nullable.');
  TTLanguage.Instance.Add(SDuplicateColumn, 'D�finition de colonne en double : %0:s.');
  TTLanguage.Instance.Add(SColumnNotFound, 'Colonne %0:s introuvable.');
  TTLanguage.Instance.Add(SRelationError, '"%0:s" est actuellement utilis�, impossible de supprimer.');
  TTLanguage.Instance.Add(SColumnTypeError, 'Colonne non enregistr�e pour le type %0:s.');
  TTLanguage.Instance.Add(SParameterTypeError, 'Param�tre non enregistr� pour le type %0:s.');
  TTLanguage.Instance.Add(STableMapNotFound, 'TableMap pour la classe %0:s introuvable');
  TTLanguage.Instance.Add(SPrimaryKeyNotDefined, 'Cl� primaire non d�finie pour la classe %0:s');
  TTLanguage.Instance.Add(SRecordChanged, 'Entit� modifi�e par un autre utilisateur.');
  TTLanguage.Instance.Add(SSyntaxError, 'Erreur d''int�grit� des donn�es : trop d''enregistrements affect�s.');
  TTLanguage.Instance.Add(STransactionNotSupported, 'La connexion ne supporte pas les transactions.');
  TTLanguage.Instance.Add(SInTransaction, '%0:s : transaction d�j� d�marr�e.');
  TTLanguage.Instance.Add(SNotInTransaction, '%0:s : transaction pas encore d�marr�e.');
  TTLanguage.Instance.Add(SNotValidTransaction, 'La transaction n''est plus valide.');
  TTLanguage.Instance.Add(SNotValidConnectionDriver, 'Connexion introuvable pour le pilote "%s".');
  TTLanguage.Instance.Add(SNotValidConnection, 'Connexion introuvable "%s".');
end;

end.

