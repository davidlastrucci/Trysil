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
| `NestedException` | `Exception` | The exception that was active when this one was raised |

`NestedException` captures the current exception object (via `AcquireExceptionObject`) at construction time. This enables exception chaining — when a Trysil exception is raised inside an `except` block, the original exception is preserved and accessible.

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
raise ETHttpException.Create(409, 'Conflict detected');
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

If a `NestedException` exists, it is included:

```json
{
  "status": 404,
  "message": "Person not found",
  "nestedException": {
    "status": 500,
    "message": "Original error details"
  }
}
```

### Convenience Subclasses

| Exception | Status Code | Usage |
|---|---|---|
| `ETHttpBadRequest` | 400 | Invalid request data |
| `ETHttpUnauthorized` | 401 | Authentication required or failed |
| `ETHttpForbidden` | 403 | Authenticated but insufficient permissions |
| `ETHttpNotFound` | 404 | Resource not found |
| `ETHttpMethodNotAllowed` | 405 | HTTP method not supported for this endpoint |
| `ETHttpInternalServerError` | 500 | Unexpected server error |

All subclasses have simplified constructors (no status code parameter):

```pascal
// In a controller method
raise ETHttpNotFound.Create('Person not found');
raise ETHttpNotFound.CreateFmt('Person %d not found', [AID]);

raise ETHttpBadRequest.Create('Missing required field: name');
raise ETHttpForbidden.Create('Insufficient permissions');
raise ETHttpUnauthorized.Create('Invalid token');
```

### TExceptionHelper

A class helper on `Exception` that adds `ToJSon` to any exception:

```pascal
try
  // ...
except
  on E: Exception do
    LResponse.Content := E.ToJSon;
end;
```

This produces `{"status":500,"message":"..."}` for any exception, with nested exception support for `ETException` descendants.

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
        └── ETHttpInternalServerError (500)
```

## Best Practices

1. **Catch specific exceptions** — handle `ETValidationException` and `ETConcurrentUpdateException` explicitly rather than catching the generic `ETException`

2. **Use HTTP exceptions in controllers** — the HTTP server automatically converts them to the appropriate HTTP response with status code and JSON body

3. **Check NestedException** — when debugging, inspect `NestedException` for the root cause of chained errors

4. **Refresh after concurrent update** — when catching `ETConcurrentUpdateException`, call `Refresh<T>` to reload the entity with the latest database state before retrying
