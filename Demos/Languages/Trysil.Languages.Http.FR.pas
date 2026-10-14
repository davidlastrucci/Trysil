unit Trysil.Languages.Http.FR;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,
  Trysil.Http.Consts,
  Trysil.Http.Log.Consts;

type

{ TTLanguageHttpFR }

  TTLanguageHttpFR = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageHttpFR }

class procedure TTLanguageHttpFR.Translate;
begin
  TTLanguage.Instance.Add(SAlreadyStarted, 'Serveur Http déjà démarré.');
  TTLanguage.Instance.Add(SAreaOnAnonymousRoute, 'La route %0:s est restreinte par [TArea] et ouverte par [TAuthorizationType(None)] : personne ne pourra jamais l''atteindre.');
  TTLanguage.Instance.Add(SAreasNeedAuthentication, 'Une route restreinte par [TArea] a besoin d''une classe d''authentification : enregistrez-en une, ou retirez l''attribut.');
  TTLanguage.Instance.Add(SAuthAlreadyRegistered, 'Authentification : classe déjà enregistrée.');
  TTLanguage.Instance.Add(SAuthenticationNotRegistered,
    'Serveur Http non démarré : un ou plusieurs contrôleurs exigent l''authentification et aucune classe d''authentification n''est enregistrée. ' +
    'Une route sans [TAuthorizationType] exige l''authentification par défaut. ' +
    'Appelez RegisterAuthentication, ou mettez AllowAnonymous à True si ce serveur doit servir chaque route de manière anonyme.');
  TTLanguage.Instance.Add(SColumnNotFilterable,
    'La colonne %s ne peut pas être utilisée dans un filtre : ce n''est pas une colonne de cette entité, ou elle est marquée comme non filtrable.');
  TTLanguage.Instance.Add(SConditionNotValid, 'Condition %s non valide.');
  TTLanguage.Instance.Add(SConditionNotValidForColumn, 'Condition %0:s non valide pour la colonne %1:s.');
  TTLanguage.Instance.Add(SContentTooLarge,
    'Le corps de la requête dépasse les %0:d octets que ce serveur accepte. Un corps est lu entièrement en mémoire avant que quiconque le regarde, ' +
    'le plafond est donc ce qui empêche une seule requête de coûter au processus plus qu''il n''a. ' +
    'Augmentez MaxRequestContentLength, ou mettez-le à zéro pour accepter n''importe quelle taille.');
  TTLanguage.Instance.Add(SDirectionNotValid, 'Direction %s non valide.');
  TTLanguage.Instance.Add(SDuplicateController, 'ControllerID(Uri/MethodType) en double : %0:s.');
  TTLanguage.Instance.Add(SDuplicateBindAddress, 'L''adresse d''écoute %0:s est déjà enregistrée : une seconde liaison sur la même adresse et le même port ne peut pas s''ouvrir.');
  TTLanguage.Instance.Add(SEmptyJWTSecret,
    'Le secret HMAC est vide : chaque signature qu''il produit peut être reproduite par n''importe qui, un jeton signé avec lui ne prouve donc rien. ' +
    'Renvoyez un vrai secret depuis GetSecret.');
  TTLanguage.Instance.Add(SEntityNotFound, 'Entité %d introuvable.');
  TTLanguage.Instance.Add(SForbidden, 'Accès interdit : %s.');
  TTLanguage.Instance.Add(SForbiddenAreaLog, 'Accès interdit : %0:s - zone manquante : %1:s.');
  TTLanguage.Instance.Add(SInternalServerError, 'Erreur interne du serveur.');
  TTLanguage.Instance.Add(SLogError, 'Erreur non gérée : %s');
  TTLanguage.Instance.Add(SLogQueueDiscarded, 'File de log pleine : %d entrées écartées pour l''hôte %s');
  TTLanguage.Instance.Add(SLogWriterAlreadyRegistered, 'LogWriter : classe déjà enregistrée.');
  TTLanguage.Instance.Add(SMethodNotAllowed, 'Méthode %0:s non autorisée pour la commande %1:s.');
  TTLanguage.Instance.Add(SMethodOverrideRefused,
    'La requête demande à être traitée comme %0:s alors qu''elle a été envoyée comme %1:s. Une méthode portée dans un en-tête passe outre tout ce qui filtre sur la ligne de requête, ' +
    'le serveur la refuse donc. Mettez AllowMethodOverride à True si ce serveur doit l''honorer.');
  TTLanguage.Instance.Add(SNoSaveOnHttpContext,
    'Save n''est pas disponible sur un TTHttpContext. Il décide entre une insertion et une mise à jour d''après ce que le contexte a créé et n''a pas encore écrit, ' +
    'et un contexte qui vit une requête n''a pas cette histoire : l''entité a été remplie depuis le corps. ' +
    'Si la requête crée ou met à jour, c''est la requête qui le dit : appelez Insert ou Update.');
  TTLanguage.Instance.Add(SNotFound, 'Commande %s introuvable.');
  TTLanguage.Instance.Add(SNotStarted, 'Serveur Http non démarré.');
  TTLanguage.Instance.Add(SRedactedNamesWhileServing,
    'La liste de rédaction ne peut pas changer pendant qu''un serveur tourne : elle est lue pour chaque en-tête et chaque ' +
    'paramètre de chaque requête, et y ajouter sous ces lecteurs est une course. Déclarez avant Start ce qui ne doit pas être journalisé.');
  TTLanguage.Instance.Add(SNotValidAuthentication, 'L''authentification %s n''est pas une TTHttpAbstractAuthentication valide.');
  TTLanguage.Instance.Add(SNotValidBaseUri,
    'BaseUri %0:s est un préfixe de chemin, pas une adresse : il est placé devant chaque route, une valeur portant un schéma enregistre donc des routes que personne ne peut atteindre. ' +
    'L''adresse sur laquelle le serveur écoute vient de Bindings.');
  TTLanguage.Instance.Add(SNotValidBindAddress,
    'L''adresse d''écoute "%0:s" n''est pas une adresse IP. Écrivez-la comme un littéral IPv4 ou IPv6, par exemple 127.0.0.1 ou ::1, ' +
    'sans port, sans crochets et sans nom d''hôte : le port vient de Port, et un nom peut se résoudre en plusieurs adresses.');
  TTLanguage.Instance.Add(SNotValidCommandType, 'Type de commande non valide %s.');
  TTLanguage.Instance.Add(SNotValidController, 'Le contrôleur %s n''est pas un TTHttpAbstractController valide.');
  TTLanguage.Instance.Add(SNotValidFilterValue, 'Le champ "%s" du filtre porte une valeur que le filtre ne sait pas lire. Un filtre illisible est refusé, non appliqué en partie.');
  TTLanguage.Instance.Add(SNotValidLogWriter, 'Le LogWriter %s n''est pas un TTHttpLogAbstractWriter valide.');
  TTLanguage.Instance.Add(SNotValidParametrizedUri,
    'La route %0:s porte un "?" qui n''est pas dans les derniers segments. Un espace réservé correspond à n''importe quelle valeur, ' +
    'un espace placé avant un segment fixe fait donc chevaucher la route avec des adresses qu''elle ne devait pas servir. Déplacez les espaces réservés à la fin de la route.');
  TTLanguage.Instance.Add(SDifferentNotSqid,
    'La route %0:s est servie par des méthodes qui marquent avec [TNotSqid] des paramètres différents. La route lit ses espaces réservés avant de connaître la méthode, ' +
    'donc toutes les méthodes d''une même route doivent marquer les mêmes positions.');
  TTLanguage.Instance.Add(SNotValidRouteParameters,
    'La méthode %0:s.%1:s a un attribut de route mais ne peut pas la servir : ses paramètres doivent être aussi nombreux que les "?" de la route, et tous entiers. ' +
    'Elle était auparavant écartée des routes sans un mot. Une chaîne ou toute autre valeur passe par la query string ou par le corps.');
  TTLanguage.Instance.Add(SNotValidTenantName,
    'Le nom de tenant "%0:s" n''est pas un nom : il doit commencer par une lettre ou un chiffre, en porter au plus 63 plus "_", "-" et ".", et rien d''autre. ' +
    'Le nom parvient à une définition de connexion et, dans la plupart des applications, à un nom de base de données ou à un chemin, et il vient généralement de la requête.');
  TTLanguage.Instance.Add(SOrderByItemNotValid, 'Clause ORDER BY non valide.');
  TTLanguage.Instance.Add(SOrderByNotValid, 'Clause ORDER BY %s non valide.');
  TTLanguage.Instance.Add(SRegisterAuth, 'Authentification enregistrée : %s');
  TTLanguage.Instance.Add(SRegisterAuthError, 'Erreur d''enregistrement de l''authentification : %s');
  TTLanguage.Instance.Add(SRegisterController, 'Contrôleur enregistré : %s');
  TTLanguage.Instance.Add(SRegisterControllerError, 'Erreur d''enregistrement du contrôleur : %s');
  TTLanguage.Instance.Add(SStartWithoutLimit, 'Un "start" de %0:d a besoin d''un "limit" : le point de terminaison est configuré sans taille de page maximale, il n''y a donc rien sur quoi se rabattre.');
  TTLanguage.Instance.Add(SNotValidFilterContent,
    'Un filtre est un objet JSon. Ce corps s''analyse en autre chose, et ni "where", ni "orderBy", ni "start", ni ' +
    '"limit" ne peuvent y être lus : l''appliquer signifierait, en silence, aucun filtre - et un filtre qui tombe est ' +
    'une restriction qui tombe.');
  TTLanguage.Instance.Add(SStarted, 'Serveur Http démarré');
  TTLanguage.Instance.Add(SStopped, 'Serveur Http arrêté');
  TTLanguage.Instance.Add(STooManyOrderByColumns, 'Trop de colonnes ORDER BY : %0:d (maximum %1:d).');
  TTLanguage.Instance.Add(STooManyWhereConditions, 'Trop de conditions WHERE : %0:d (maximum %1:d).');
  TTLanguage.Instance.Add(SUnauthorized, 'Accès non autorisé : %s.');
  TTLanguage.Instance.Add(SUnhandledRequestError, '%0:s non gérée hors du gestionnaire de requête : %1:s');
  TTLanguage.Instance.Add(SValueNotValid, 'Valeur %0:s non valide pour la colonne %1:s.');
  TTLanguage.Instance.Add(SWhereNotValid, 'Clause WHERE non valide.');
  TTLanguage.Instance.Add(SNotValidJSonContent,
    'Le corps de la requête n''est pas du JSON valide. Un corps illisible est refusé plutôt que traité comme un objet vide : ' +
    'un filtre construit à partir d''un objet vide ne porte aucune condition, et le point de terminaison répondrait avec la table entière.');
end;

end.
