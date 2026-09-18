# Exceptions

## Core Exceptions

Unit: `Trysil.Exceptions`

### ETException

Base exception for all Trysil errors.

```pascal
raise ETException.Create('Something went wrong');
raise ETException.CreateFmt('Entity %d not found', [LId]);
```

| Property | Type | Description |
|---|---|---|
| `Message` | `String` | Error message (inherited from `Exception`) |
| `HasNestedException` | `Boolean` | Whether an exception was in flight when this one was raised |
| `NestedExceptionClassName` | `String` | Class name of the exception that was active |
| `NestedExceptionMessage` | `String` | Message of the exception that was active |

At construction time the exception records the **class name and message** of whatever exception is currently being handled, read through `ExceptObject`. It does not take ownership of that object: `AcquireExceptionObject` would detach the exception from its raise frame and free it in this exception's destructor, which breaks a plain `raise;` further up the stack. The chain is diagnostic text, not a live object graph.

### ETValidationException

Raised when entity validation fails. Extends `ETException`.

```pascal
try
  LContext.Insert<TPerson>(LPerson);
except
  on E: ETValidationException do
    ShowMessage(E.Message);
end;
```

Validation errors are collected in `TTValidationErrors` before being raised as this exception.

### ETConcurrentUpdateException

Raised when an optimistic locking conflict is detected — the record's version in the database does not match the version in the entity (another transaction modified it).

It is also what an `Update`, or a second `Delete`, on a **soft-deleted** row raises. The `WHERE` clause carries `DeletedAt IS NULL` - for the entity that declares the pair; the guard comes from the mapping, not from the table - so a deleted row is unreachable: zero rows affected therefore means the version moved **or** the row is no longer available, and the two are not distinguishable from the exception. `Undelete` is the way back, and it is the one operation the guard does not apply to.

```pascal
try
  LContext.Update<TPerson>(LPerson);
except
  on E: ETConcurrentUpdateException do
  begin
    // Refresh and retry, or notify the user
    LContext.Refresh<TPerson>(LPerson);
    ShowMessage('Record was modified by another user.');
  end;
end;
```

### ETDataIntegrityException

Raised when a write reports **more than one affected row**. Every `UPDATE` and
`DELETE` Trysil issues is addressed by the primary key, so a second row means
the key does not identify a row on its own - a duplicate, or a mapping pointing
at the wrong table. Zero rows is the other case and raises
`ETConcurrentUpdateException` instead.

```pascal
try
  LContext.Update<TPerson>(LPerson);
except
  on E: ETDataIntegrityException do
    ShowMessage('The primary key matched more than one row.');
end;
```

!!! warning "A blocked cascade delete does not raise this"
    Deleting an entity whose `[TRelation]` has cascade `False` while children
    exist raises a plain **`ETException`**, not this one. Catch `ETException`
    for that case, or check the relation yourself before deleting.

---

## HTTP Exceptions

Unit: `Trysil.Http.Exceptions`

### ETHttpServerException

Internal server infrastructure exception. Extends `ETException`.

### ETHttpException

Base class for HTTP-specific exceptions with a status code.

```pascal
raise ETHttpException.Create(429, 'Too many requests');
raise ETHttpException.CreateFmt(422, 'Invalid field: %s', ['email']);
```

| Property | Type | Description |
|---|---|---|
| `StatusCode` | `Integer` | HTTP status code |
| `Message` | `String` | Error message |

#### ToJSon

Returns a structured JSON error response:

```pascal
var LJson := LException.ToJSon;
// {"status":404,"message":"Person not found"}
```

`ETHttpException.ToJSon` emits **only** `status` and `message`. The nested exception chain is deliberately left out: 4xx responses are reachable without authentication, and the chain carries the message of the original exception -- file paths, SQL text, connection details.

The generic 5xx path emits no detail at all. The listener routes by **status code, not by class**: any response of 500 or above -- an `ETHttpException` carrying such a status included -- reaches the client as `TTHttpErrorResponse.ToJSon`, a fixed body carrying only the task identifier:

```json
{
  "status": 500,
  "message": "Internal server error.",
  "taskId": "9f2c1ab4e77d4b0e8c1d5f3a6b90c2e4"
}
```

So `raise ETHttpInternalServerError.Create(E.Message)` does **not** put that message on the wire: routing by class would have left the hole open for the most natural thing a host can write.

The exception class, its message and the recorded nested class and message go to the log writer instead, through `WriteError(ALogError: TTHttpLogError)`, rendered to strings on the request thread before the entry is queued. The full detail behind any error belongs in the correlated log entry, keyed by `TaskID`, not in the response body.

!!! warning "A log writer is required to see that detail"
    `WriteError` is only called when one is registered. An application that never calls `RegisterLogWriter` now has a 5xx with no detail anywhere: not in the response, which is the point, and not in a log, which is the consequence. Before this change the message reached the client, so no writer was needed to diagnose an incident.

### Convenience Subclasses

| Exception | Status Code | Usage |
|---|---|---|
| `ETHttpBadRequest` | 400 | Invalid request data |
| `ETHttpUnauthorized` | 401 | Authentication required or failed |
| `ETHttpForbidden` | 403 | Authenticated but insufficient permissions |
| `ETHttpNotFound` | 404 | Resource not found |
| `ETHttpMethodNotAllowed` | 405 | HTTP method not supported for this endpoint |
| `ETHttpConflict` | 409 | Version conflict or integrity violation |
| `ETHttpUnprocessableContent` | 422 | The body parses but the entity refuses it |
| `ETHttpInternalServerError` | 500 | Unexpected server error |

All subclasses have simplified constructors (no status code parameter):

```pascal
// In a controller method
raise ETHttpNotFound.Create('Person not found');
raise ETHttpNotFound.CreateFmt('Person %d not found', [AID]);

raise ETHttpBadRequest.Create('Missing required field: name');
raise ETHttpForbidden.Create('Insufficient permissions');
raise ETHttpUnauthorized.Create('Invalid token');
raise ETHttpConflict.Create('The record was modified by another user');
```

Two of them the listener raises for you. An `ETConcurrentUpdateException` that escapes a controller becomes **409**, and an `ETValidationException` becomes **422**, both carrying the original message in the usual `status` / `message` body. Neither used to be an `ETHttpException`, so both came out as a `500` with no detail - and a `500` tells a client to retry the same request, which is exactly wrong for both. A controller that wants a different status still raises `ETHttpConflict` or `ETHttpBadRequest` itself; an `ETDataIntegrityException` is not mapped, because whether a foreign key violation is the caller's fault or the schema's is not something the library can decide. Both are logged with `LogAction`, not `LogError`: they are the caller's problem, not a server fault, but a 409 or a 422 that nobody can find afterwards is not much use either.

!!! warning "The 422 body carries your column names"
    The message of an `ETValidationException` is the list of failures, one per line, each naming the column that failed. That name is `[TDisplayName]` when the field declares one and **the database column name** when it does not, so on a route that anyone can call - a sign-up form, a contact request - the reply enumerates your schema, and validators like `[TMaxLength]` add the bound as well. That is also the point of a 422: the client has to know which field to fix. Declare `[TDisplayName]` on the fields whose column names you would rather not publish.

    What never reaches the client is an exception raised **inside** a validator. Those used to be caught and added to the error list, which put a FireDAC message - constraint, table, statement - into the same body. They now propagate, and a validator that fails is a `500`.

### TTHttpErrorResponse

The fixed body the listener returns for every response of status 500 or above:

```pascal
LResponse.Content := TTHttpErrorResponse.ToJSon(FRequest.TaskID.ToString);
LResponse.Content := TTHttpErrorResponse.ToJSon(503, FRequest.TaskID.ToString);
```

It produces `{"status":500,"message":"Internal server error.","taskId":"..."}` and nothing else. The overload keeps the caller's status code, so a 503 stays a 503; the message is the same constant in either case, deliberately, because it is the only thing guaranteed to leak nothing.

It replaces the old `TExceptionHelper` class helper, which serialized the exception message and its chain straight to the client.

---

## Exception Hierarchy

```
Exception
+-- ETException
|   +-- ETValidationException
|   +-- ETConcurrentUpdateException
|   +-- ETDataIntegrityException
|   +-- ETJSonException
|   |   +-- ETJSonServerException
|   +-- ETTenantUnavailable
|   |   +-- ETTenantNameNotValid
|   +-- ETHttpServerException
|   +-- ETHttpException
|       +-- ETHttpBadRequest (400)
|       +-- ETHttpUnauthorized (401)
|       +-- ETHttpForbidden (403)
|       +-- ETHttpNotFound (404)
|       +-- ETHttpMethodNotAllowed (405)
|       +-- ETHttpConflict (409)
|       +-- ETHttpContentTooLarge (413)
|       +-- ETHttpUnprocessableContent (422)
|       +-- ETHttpInternalServerError (500)
+-- ETHttpJWTException
```

!!! warning "`ETHttpJWTException` is not an `ETException`"
    It descends straight from `Exception`, so `on E: ETException` does **not**
    catch it. Name it explicitly, or catch `Exception`, wherever you build or
    verify a token by hand. Inside a controller the listener turns it into a
    `500`, like any other unmapped exception.

## Best Practices

1. **Catch specific exceptions** — handle `ETValidationException` and `ETConcurrentUpdateException` explicitly rather than catching the generic `ETException`

2. **Use HTTP exceptions in controllers** — the HTTP server automatically converts them to the appropriate HTTP response with status code and JSON body

3. **Check the nested exception** — when debugging, inspect `NestedExceptionClassName` and `NestedExceptionMessage` for the root cause of chained errors

4. **Refresh after concurrent update** — when catching `ETConcurrentUpdateException`, call `Refresh<T>` to reload the entity with the latest database state before retrying
