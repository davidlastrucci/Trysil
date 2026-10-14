# Languages

Translation units for localizing Trysil error messages. There is one unit per package and per language, so a project only includes the units of the packages it uses.

## Available Languages

| Package | Italian | French |
|---|---|---|
| `Trysil` | `Trysil.Languages.IT.pas` | `Trysil.Languages.FR.pas` |
| `Trysil.JSon` | `Trysil.Languages.JSon.IT.pas` | `Trysil.Languages.JSon.FR.pas` |
| `Trysil.Http` | `Trysil.Languages.Http.IT.pas` | `Trysil.Languages.Http.FR.pas` |
| `Trysil.OpenAPI` | `Trysil.Languages.OpenAPI.IT.pas` | `Trysil.Languages.OpenAPI.FR.pas` |

## Usage

Add the units of the packages your project uses to its `uses` clause and call each `Translate` at startup. For a REST server in Italian:

```pascal
uses
  Trysil.Languages.IT,
  Trysil.Languages.JSon.IT,
  Trysil.Languages.Http.IT;

begin
  TTLanguageIT.Translate;
  TTLanguageJSonIT.Translate;
  TTLanguageHttpIT.Translate;
  // ...
end;
```

A desktop application that uses only the `Trysil` package needs `Trysil.Languages.IT` alone.

`Trysil.Languages.IT` and `Trysil.Languages.FR` used to translate the messages of every package. They now translate only the `Trysil` package: a project that relied on them for the JSON and HTTP messages still compiles, but those messages are back in English until it adds the matching units.

## Adding a New Language

1. Copy the files of one of the existing languages (e.g., `Trysil.Languages.IT.pas`, `Trysil.Languages.JSon.IT.pas`, ...).
2. Rename the classes and units (e.g., `TTLanguageDE` in `Trysil.Languages.DE.pas`, `TTLanguageJSonDE` in `Trysil.Languages.JSon.DE.pas`).
3. Translate all string values passed to `TTLanguage.Instance.Add()`.
