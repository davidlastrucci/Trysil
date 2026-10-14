unit Trysil.Languages.Http.IT;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,
  Trysil.Http.Consts,
  Trysil.Http.Log.Consts;

type

{ TTLanguageHttpIT }

  TTLanguageHttpIT = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageHttpIT }

class procedure TTLanguageHttpIT.Translate;
begin
  TTLanguage.Instance.Add(SAlreadyStarted, 'Server Http già avviato.');
  TTLanguage.Instance.Add(SAreaOnAnonymousRoute, 'La rotta %0:s è limitata con [TArea] e aperta con [TAuthorizationType(None)]: nessuno potrà mai raggiungerla.');
  TTLanguage.Instance.Add(SAreasNeedAuthentication, 'Una rotta limitata con [TArea] ha bisogno di una classe di autenticazione: registrane una, o togli l''attributo.');
  TTLanguage.Instance.Add(SAuthAlreadyRegistered, 'Autenticazione: classe già registrata.');
  TTLanguage.Instance.Add(SAuthenticationNotRegistered,
    'Server Http non avviato: uno o più controller richiedono l''autenticazione e non è registrata nessuna classe di autenticazione. ' +
    'Una rotta senza [TAuthorizationType] richiede l''autenticazione per difetto. ' +
    'Chiama RegisterAuthentication, oppure metti AllowAnonymous a True se questo server deve servire ogni rotta in modo anonimo.');
  TTLanguage.Instance.Add(SColumnNotFilterable,
    'La colonna %s non si può usare in un filtro: non è una colonna di questa entità, oppure è marcata come non filtrabile.');
  TTLanguage.Instance.Add(SConditionNotValid, 'Condizione %s non valida.');
  TTLanguage.Instance.Add(SConditionNotValidForColumn, 'Condizione %0:s non valida per la colonna %1:s.');
  TTLanguage.Instance.Add(SContentTooLarge,
    'Il corpo della richiesta supera i %0:d byte che questo server accetta. Un corpo viene letto in memoria per intero prima che qualcuno lo guardi, ' +
    'quindi il tetto è ciò che impedisce a una sola richiesta di costare al processo più di quanto abbia. ' +
    'Alza MaxRequestContentLength, o mettilo a zero per accettare qualunque dimensione.');
  TTLanguage.Instance.Add(SDirectionNotValid, 'Direzione %s non valida.');
  TTLanguage.Instance.Add(SDuplicateController, 'ControllerID(Uri/MethodType) duplicato: %0:s.');
  TTLanguage.Instance.Add(SDuplicateBindAddress, 'L''indirizzo di binding %0:s è già registrato: un secondo binding sullo stesso indirizzo e sulla stessa porta non si può aprire.');
  TTLanguage.Instance.Add(SEmptyJWTSecret,
    'Il segreto HMAC è vuoto: ogni firma che produce può essere riprodotta da chiunque, quindi un token firmato con quello non dimostra niente. ' +
    'Restituisci un segreto vero da GetSecret.');
  TTLanguage.Instance.Add(SEntityNotFound, 'Entità %d non trovata.');
  TTLanguage.Instance.Add(SForbidden, 'Accesso vietato: %s.');
  TTLanguage.Instance.Add(SForbiddenAreaLog, 'Accesso vietato: %0:s - area mancante: %1:s.');
  TTLanguage.Instance.Add(SInternalServerError, 'Errore interno del server.');
  TTLanguage.Instance.Add(SLogError, 'Errore non gestito: %s');
  TTLanguage.Instance.Add(SLogQueueDiscarded, 'Coda di log piena: %d voci scartate per l''host %s');
  TTLanguage.Instance.Add(SLogWriterAlreadyRegistered, 'LogWriter: classe già registrata.');
  TTLanguage.Instance.Add(SMethodNotAllowed, 'Metodo %0:s non ammesso per il comando %1:s.');
  TTLanguage.Instance.Add(SMethodOverrideRefused,
    'La richiesta chiede di essere trattata come %0:s mentre è stata mandata come %1:s. Un metodo portato in un header scavalca tutto ciò che filtra sulla riga di richiesta, ' +
    'quindi il server la rifiuta. Metti AllowMethodOverride a True se questo server deve onorarlo.');
  TTLanguage.Instance.Add(SNoSaveOnHttpContext,
    'Save non è disponibile su un TTHttpContext. Decide fra un insert e un update da quello che il contesto ha creato e non ha ancora scritto, ' +
    'e un contesto che vive una richiesta non ha questa storia: l''entità è stata riempita dal corpo. ' +
    'Se la richiesta crea o aggiorna lo dice la richiesta, quindi chiama Insert o Update.');
  TTLanguage.Instance.Add(SNotFound, 'Comando %s non trovato.');
  TTLanguage.Instance.Add(SNotStarted, 'Server Http non avviato.');
  TTLanguage.Instance.Add(SRedactedNamesWhileServing,
    'La lista di redazione non si può cambiare mentre un server è in esecuzione: viene letta a ogni header e a ogni parametro ' +
    'di ogni richiesta, e aggiungerci qualcosa sotto quei lettori è una corsa. Dichiara cosa non deve finire nel log prima di Start.');
  TTLanguage.Instance.Add(SNotValidAuthentication, 'L''autenticazione %s non è una TTHttpAbstractAuthentication valida.');
  TTLanguage.Instance.Add(SNotValidBaseUri,
    'BaseUri %0:s è un prefisso di percorso, non un indirizzo: viene messo davanti a ogni rotta, quindi un valore che porta uno schema registra rotte che nessuno può raggiungere. ' +
    'L''indirizzo su cui il server ascolta viene da Bindings.');
  TTLanguage.Instance.Add(SNotValidBindAddress,
    'L''indirizzo di binding "%0:s" non è un indirizzo IP. Va scritto come letterale IPv4 o IPv6, per esempio 127.0.0.1 o ::1, ' +
    'senza porta, senza parentesi quadre e senza nome host: la porta viene da Port, e un nome può risolvere a più di un indirizzo.');
  TTLanguage.Instance.Add(SNotValidCommandType, 'Tipo di comando non valido %s.');
  TTLanguage.Instance.Add(SNotValidController, 'Il controller %s non è un TTHttpAbstractController valido.');
  TTLanguage.Instance.Add(SNotValidFilterValue, 'Il campo "%s" del filtro porta un valore che il filtro non sa leggere. Un filtro che non si può leggere viene rifiutato, non applicato in parte.');
  TTLanguage.Instance.Add(SNotValidLogWriter, 'Il LogWriter %s non è un TTHttpLogAbstractWriter valido.');
  TTLanguage.Instance.Add(SNotValidParametrizedUri,
    'La rotta %0:s porta un "?" che non sta negli ultimi segmenti. Un segnaposto combacia con qualunque valore, ' +
    'quindi uno messo prima di un segmento fisso fa sovrapporre la rotta a indirizzi che non doveva servire. Sposta i segnaposto in fondo alla rotta.');
  TTLanguage.Instance.Add(SDifferentNotSqid,
    'La rotta %0:s è servita da metodi che marcano con [TNotSqid] parametri diversi. La rotta legge i segnaposto prima di sapere quale metodo chiamare, ' +
    'quindi tutti i metodi sulla stessa rotta devono marcare le stesse posizioni.');
  TTLanguage.Instance.Add(SNotValidRouteParameters,
    'Il metodo %0:s.%1:s ha un attributo di rotta ma non può servirla: i suoi parametri devono essere tanti quanti i "?" della rotta, e tutti interi. ' +
    'Prima veniva escluso dalle rotte senza dire niente. Una stringa o un altro valore viaggia nella query string o nel body.');
  TTLanguage.Instance.Add(SNotValidTenantName,
    'Il nome tenant "%0:s" non è un nome: deve iniziare con una lettera o una cifra, portarne al più 63 più "_", "-" e ".", e nient''altro. ' +
    'Il nome arriva a una definizione di connessione e, nella maggior parte delle applicazioni, a un nome di database o a un percorso, e di solito viene dalla richiesta.');
  TTLanguage.Instance.Add(SOrderByItemNotValid, 'Clausola ORDER BY non valida.');
  TTLanguage.Instance.Add(SOrderByNotValid, 'Clausola ORDER BY %s non valida.');
  TTLanguage.Instance.Add(SRegisterAuth, 'Autenticazione registrata: %s');
  TTLanguage.Instance.Add(SRegisterAuthError, 'Errore di registrazione dell''autenticazione: %s');
  TTLanguage.Instance.Add(SRegisterController, 'Controller registrato: %s');
  TTLanguage.Instance.Add(SRegisterControllerError, 'Errore di registrazione del controller: %s');
  TTLanguage.Instance.Add(SStartWithoutLimit, 'Uno "start" di %0:d ha bisogno di un "limit": l''endpoint è configurato senza una dimensione massima di pagina, quindi non c''è niente su cui ripiegare.');
  TTLanguage.Instance.Add(SNotValidFilterContent,
    'Un filtro è un oggetto JSon. Questo corpo parsa in qualcos''altro, e da lì non si possono leggere né "where" ' +
    'né "orderBy" né "start" né "limit": applicarlo vorrebbe dire, in silenzio, nessun filtro - e un filtro che cade ' +
    'è una restrizione che cade.');
  TTLanguage.Instance.Add(SStarted, 'Server Http avviato');
  TTLanguage.Instance.Add(SStopped, 'Server Http fermato');
  TTLanguage.Instance.Add(STooManyOrderByColumns, 'Troppe colonne in ORDER BY: %0:d (massimo %1:d).');
  TTLanguage.Instance.Add(STooManyWhereConditions, 'Troppe condizioni in WHERE: %0:d (massimo %1:d).');
  TTLanguage.Instance.Add(SUnauthorized, 'Accesso non autorizzato: %s.');
  TTLanguage.Instance.Add(SUnhandledRequestError, '%0:s non gestita fuori dal gestore della richiesta: %1:s');
  TTLanguage.Instance.Add(SValueNotValid, 'Valore %0:s non valido per la colonna %1:s.');
  TTLanguage.Instance.Add(SWhereNotValid, 'Clausola WHERE non valida.');
  TTLanguage.Instance.Add(SNotValidJSonContent,
    'Il corpo della richiesta non è JSON valido. Un corpo che non si riesce a leggere viene rifiutato invece di essere trattato come un oggetto vuoto: ' +
    'un filtro costruito da un oggetto vuoto non porta nessuna condizione, e l''endpoint risponderebbe con la tabella intera.');
end;

end.
