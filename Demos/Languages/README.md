# Languages

Translation units for localizing Trysil error messages. Include one of these units in your project to display framework messages in the target language.

## Available Languages

| Unit | Language |
|---|---|
| `Trysil.Languages.IT.pas` | Italian |
| `Trysil.Languages.FR.pas` | French |

## Usage

Add the unit to your project's `uses` clause and call `Translate` at startup:

```pascal
uses
  Trysil.Languages.IT;

begin
  TTLanguageIT.Translate;
  // ...
end;
```

All Trysil error messages (validation errors, transaction failures, entity lifecycle messages, etc.) will be displayed in the selected language.

## Adding a New Language

1. Copy one of the existing files (e.g., `Trysil.Languages.IT.pas`).
2. Rename the class and unit (e.g., `TTLanguageDE` in `Trysil.Languages.DE.pas`).
3. Translate all string values passed to `TTLanguage.Instance.Add()`.
