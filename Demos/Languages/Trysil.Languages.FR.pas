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
  TTLanguage.Instance.Add(SDuplicateChangedAtAttribute, 'Attribut "At" de suivi des modifications en double : %0:s.');
  TTLanguage.Instance.Add(SDuplicateChangedByAttribute, 'Attribut "By" de suivi des modifications en double : %0:s.');
  TTLanguage.Instance.Add(SInvalidChangedAtType, 'L''attribut "At" de suivi des modifications requiert un champ TTNullable<TDateTime> : %0:s.');
  TTLanguage.Instance.Add(SInvalidChangedByType, 'L''attribut "By" de suivi des modifications requiert un champ String : %0:s.');
  TTLanguage.Instance.Add(SDeletedByWithoutDeletedAt, 'TDeletedBy requiert une colonne TDeletedAt : %0:s.');
  TTLanguage.Instance.Add(SDuplicateChangeTrackingColumn, 'La colonne %0:s porte plus d''un attribut de suivi des modifications.');
  TTLanguage.Instance.Add(SInstanceDestroyed, 'L''instance de %0:s n''est plus disponible : l''unite a ete finalisee.');
  TTLanguage.Instance.Add(SInsertEventAttribute, 'Attribut TInsertEventAttribute en double.');
  TTLanguage.Instance.Add(SUpdateEventAttribute, 'Attribut TUpdateEventAttribute en double.');
  TTLanguage.Instance.Add(SDeleteEventAttribute, 'Attribut TDeleteEventAttribute en double.');
  TTLanguage.Instance.Add(SEventsAlreadyRegistered, 'Les événements de %0:s sont déjà enregistrés.');
  TTLanguage.Instance.Add(SEventClassNotAssigned, 'Impossible d''enregistrer les événements de %0:s : la classe d''événement est nil.');
  TTLanguage.Instance.Add(SEventsAttributeAndRegistration, 'Les événements de %0:s sont déclarés à la fois par un attribut et par un enregistrement : n''en garder qu''un.');
  TTLanguage.Instance.Add(SNotDefinedPrimaryKey, 'Clé primaire : non définie.');
  TTLanguage.Instance.Add(SNotValidPrimaryKeyType, 'Clé primaire : type non valide.');
  TTLanguage.Instance.Add(SNotDefinedSequence, 'Séquence : non définie.');
  TTLanguage.Instance.Add(SReadOnly, '"Clé primaire" et "Colonne de version" doivent être toutes les deux définies.');
  TTLanguage.Instance.Add(SReadOnlyPrimaryKey, '"Clé primaire" n''est pas définie.');
  TTLanguage.Instance.Add(SRequiredValidation, '%0:s ne peut pas être vide.');
  TTLanguage.Instance.Add(SRequiredRelationValidation, '%0:s fait référence à une ligne qui n''existe pas.');
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
  TTLanguage.Instance.Add(SDuplicateParameterName, 'Les colonnes %0:s et %1:s donnent le même nom de paramètre %2:s : l''une écraserait l''autre sans un mot.');
  TTLanguage.Instance.Add(SDetailColumnOnJoinEntity,
    'La colonne de détail %0:s n''est pas résolvable sur %1:s, qui mappe une jointure : les métadonnées d''une entité ' +
    'jointe sont indexées sur l''alias de sortie de chaque colonne, donc le nom porté par [TDetailColumn] n''en rencontre ' +
    'jamais un, et la référence arriverait au moteur non qualifiée et ambiguë. Chargez le détail avec un filtre sur une entité à table unique.');
  TTLanguage.Instance.Add(SRelationError, '"%0:s" est actuellement utilisé, impossible de supprimer.');
  TTLanguage.Instance.Add(SColumnTypeError, 'Colonne non enregistrée pour le type %0:s.');
  TTLanguage.Instance.Add(SParameterTypeError, 'Paramètre non enregistré pour le type %0:s.');
  TTLanguage.Instance.Add(STableMapNotFound, 'TableMap pour la classe %0:s introuvable');
  TTLanguage.Instance.Add(SPrimaryKeyNotDefined, 'Clé primaire non définie pour la classe %0:s');
  TTLanguage.Instance.Add(SRecordChanged, 'Entité modifiée par un autre utilisateur, ou non disponible.');
  TTLanguage.Instance.Add(SSyntaxError, 'Erreur d''intégrité des données : trop d''enregistrements affectés.');
  TTLanguage.Instance.Add(SSequenceOutOfRange, 'La séquence de la table "%0:s" a renvoyé %1:d : la valeur n''entre pas dans une clé primaire. Déclarez la séquence avec un plafond de 32 bits, pour que la base la refuse à la source.');
  TTLanguage.Instance.Add(STransactionNotSupported, 'La connexion ne supporte pas les transactions.');
  TTLanguage.Instance.Add(SInTransaction, '%0:s : transaction déjà démarrée.');
  TTLanguage.Instance.Add(SNotInTransaction, '%0:s : transaction pas encore démarrée.');
  TTLanguage.Instance.Add(SNotValidTransaction, 'La transaction n''est plus valide.');
  TTLanguage.Instance.Add(SProcNotAssigned, 'La procédure n''est pas assignée.');
  TTLanguage.Instance.Add(SNestedRollbackNotSupported, 'RollbackOnDestroy n''est pas supporté dans une autre transaction.');
  TTLanguage.Instance.Add(SNotValidConnectionDriver, 'Connexion introuvable pour le pilote "%s".');
  TTLanguage.Instance.Add(SNotValidConnection, 'Connexion introuvable "%s".');
  TTLanguage.Instance.Add(SJoinEntityReadOnly, 'Les entités de jointure sont en lecture seule : Insert, Update et Delete ne sont pas pris en charge.');
  TTLanguage.Instance.Add(SUndeleteNotImplemented, '%s n''implemente pas CreateUndeleteCommand.');
  TTLanguage.Instance.Add(SConnectionAlreadyRegistered, 'La connexion "%s" est deja enregistree avec d''autres parametres.');
  TTLanguage.Instance.Add(SNoUpdatableColumns, 'La table %0:s n''a aucune colonne modifiable : chaque colonne mappee est la cle primaire, ou une colonne de suivi de creation ou de suppression.');
  TTLanguage.Instance.Add(SPagingStartWithoutLimit, 'Un debut de page requiert une limite : %0:d lignes ignorees mais aucune taille de page.');
  TTLanguage.Instance.Add(SPoolConfigConnectionRegistered, 'Les parametres de pool de la connexion "%s" ne peuvent pas changer : la connexion est deja enregistree, et le pooling s''applique a l''enregistrement.');
  TTLanguage.Instance.Add(SRawFilterOnlyParameters, 'Un filtre SQL brut ne porte que des parametres : ecrivez WHERE, ORDER BY et la pagination dans le SQL lui-meme.');
  TTLanguage.Instance.Add(SUndeleteNotSupported, 'Undelete n''est pas pris en charge : l''entité n''a pas de colonne de suppression logique.');
  TTLanguage.Instance.Add(SColumnAndDetailColumn,
    'Le membre %0:s porte à la fois TColumn et TDetailColumn. L''un mappe une valeur de cette ligne, l''autre une collection d''une autre table, ' +
    'et lequel des deux l''emportait dépendait de l''ordre dans lequel les attributs avaient été écrits.');
  TTLanguage.Instance.Add(SDuplicateEntityIdentity, 'Identity map : une autre instance de %0:s est déjà enregistrée avec la clé primaire %1:d.');
  TTLanguage.Instance.Add(SKeyColumnWithChangeTracking,
    'La colonne %0:s est la %1:s et porte aussi un attribut de suivi des modifications. Ces colonnes sont écrites par le framework à l''insertion, ' +
    'à la mise à jour ou à la suppression, et il n''appartient pas au framework de déplacer ces deux-là.');
  TTLanguage.Instance.Add(SMetadataProbeFailed,
    'La base de données a refusé la liste des colonnes de l''entité %0:s sur la table %1:s. Une colonne que l''entité mappe est absente, ' +
    'ou n''est pas lisible sous le nom auquel elle est mappée. Le moteur a dit : %2:s');
  TTLanguage.Instance.Add(SNoMappedColumns, 'L''entité %0:s ne mappe aucune colonne. Il n''y a rien à lire et rien à écrire, la requête serait donc construite vide.');
  TTLanguage.Instance.Add(SNotAssignedPrimaryKey,
    'La colonne %0:s est la clé primaire et vaut zéro : rien n''a donné d''identité à cette entité. CreateEntity en assigne une depuis la séquence, ' +
    'et une entité remplie depuis l''extérieur - un corps JSON, un import - a besoin de SetSequenceID avant d''être insérée.');
  TTLanguage.Instance.Add(SNotEscapableObjectName,
    'Le nom %0:s porte un %1:s, et %2:s n''a aucun échappement pour un tel caractère à l''intérieur d''un identifiant ' +
    'quoté : le nom se terminerait là, et ce qui suit serait lu comme du SQL. Renommez l''objet, ou mappez-le sous un nom ' +
    'qui n''en porte pas.');
  TTLanguage.Instance.Add(SNotValidParameterName,
    'La colonne %0:s porte un %1:s, qui ne peut pas figurer dans le nom d''un paramètre : le pilote lit le nom jusqu''à ce ' +
    'caractère et la valeur n''est jamais liée, donc la colonne se lit et ne s''écrit pas. Renommez-la dans la base.');
  TTLanguage.Instance.Add(SNotValidEntityList, 'Liste d''entités non valide : "%0:s" n''est pas une TTObjectList<T>.');
  TTLanguage.Instance.Add(SNotValidTableName,
    'L''entité %0:s n''a pas de table : une requête sur elle lirait "FROM " et échouerait dans le pilote. ' +
    'Ajoutez [TTable(''nom'')], ou utilisez RawSelect si la classe est un DTO pour une requête que vous écrivez vous-même.');
  TTLanguage.Instance.Add(SOldEntityAfterCommand,
    'OldEntity a été lue pour la première fois après l''exécution de la commande, et à ce moment-là la ligne dans la base est la nouvelle. ' +
    'Lisez-la dans DoBefore, où elle signifie ce que son nom dit : la valeur est conservée, DoAfter peut donc utiliser ce que DoBefore a lu.');
  TTLanguage.Instance.Add(SPrimaryKeyIsVersionColumn,
    'La colonne %0:s est à la fois la clé primaire et la colonne de version. Une mise à jour lirait "SET %0:s = %0:s + 1 WHERE %0:s = :%0:s", ' +
    'c''est-à-dire déplacerait la clé de la ligne qu''elle identifie.');
  TTLanguage.Instance.Add(SStopTransactionError,
    'La transaction n''a pas pu être fermée pendant la destruction de l''objet qui la possède, et un destructeur n''est pas un endroit d''où lever, ' +
    'l''échec est donc rapporté ici : %0:s - %1:s.');
  TTLanguage.Instance.Add(SStringTooLong, 'La valeur de "%0:s" est trop longue : la colonne contient %1:d caractères, %2:d ont été donnés.');
end;

end.
