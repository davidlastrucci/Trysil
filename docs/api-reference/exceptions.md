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

Raised when a referential integrity constraint is violated — typically when deleting an entity that has dependent child records (with `TRelation` cascade set to `False`).

```pascal
try
  LContext.Delete<TCompany>(LCompany);
except
  on E: ETDataIntegrityException do
    ShowMessage('Cannot delete: company has employees.');
end;
```

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

`ETHttpConflict` is the one to raise when an `ETConcurrentUpdateException` or an `ETDataIntegrityException` reaches a controller: the mapping is still yours to write, but the status code has a name.

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
└── ETException
    ├── ETValidationException
    ├── ETConcurrentUpdateException
    ├── ETDataIntegrityException
    └── ETHttpServerException
    └── ETHttpException
        ├── ETHttpBadRequest (400)
        ├── ETHttpUnauthorized (401)
        ├── ETHttpForbidden (403)
        ├── ETHttpNotFound (404)
        ├── ETHttpMethodNotAllowed (405)
        ├── ETHttpConflict (409)
        └── ETHttpInternalServerError (500)
```

## Best Practices

1. **Catch specific exceptions** — handle `ETValidationException` and `ETConcurrentUpdateException` explicitly rather than catching the generic `ETException`

2. **Use HTTP exceptions in controllers** — the HTTP server automatically converts them to the appropriate HTTP response with status code and JSON body

3. **Check the nested exception** — when debugging, inspect `NestedExceptionClassName` and `NestedExceptionMessage` for the root cause of chained errors

4. **Refresh after concurrent update** — when catching `ETConcurrentUpdateException`, call `Refresh<T>` to reload the entity with the latest database state before retrying
