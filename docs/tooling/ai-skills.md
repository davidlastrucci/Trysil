# AI Assistant Skills

Trysil ships ready-made **skills** — instruction files that teach an AI coding assistant how to use the Trysil API correctly: entity mapping, CRUD and queries, JSON serialization, and REST hosting. Installed into your project, they let your coding agent write real Trysil code instead of guessing.

The skills cover three areas:

| Skill | Covers |
|---|---|
| `trysil-orm` | `TTContext`, entity mapping attributes, CRUD, `TTFilterBuilder<T>`, `TTSession<T>`, lazy loading, change tracking & soft delete, JOIN queries, `RawSelect` |
| `trysil-json` | `TTJSonContext`, serialization & deserialization, `DatasetToJSon`, `MetadataToJSon` |
| `trysil-http` | Attribute-routed controllers, `TTHttpServer`, authentication, CORS, multi-tenant hosting |

## Installing from the Trysil Expert

The [Trysil Expert](../getting-started/installation.md#expert-installation-optional) installs the skills for you:

1. Open the project you are working on in the Delphi IDE.
2. Choose **Trysil → Install AI assistant skills** from the menu.
3. Select the coding assistants you use — you can pick more than one.
4. Click **Install**.

The Expert downloads the current skills and writes them into your project, each in the layout its tool expects:

| Assistant | Installed as |
|---|---|
| Claude Code | `.claude/skills/<skill>/SKILL.md` |
| Cursor | `.cursor/rules/<skill>.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Windsurf | `.windsurf/rules/<skill>.md` |
| Other / generic | `llm/<skill>.md` + `llms.txt` |

If a target file already exists, the Expert lists what would be overwritten and asks for confirmation before continuing.

!!! note "Stay on the latest Trysil"
    The skills always track the latest Trysil API. Keep your Trysil up to date to use them.

## Installing manually

The skills live in their own repository: [`trysil-ai-skills`](https://github.com/davidlastrucci/trysil-ai-skills). Each assistant has a ready-made folder — copy its contents into the root of your project. See the repository README for details.

## What gets installed

These are plain Markdown instruction files: they contain no code and change nothing in your application. They only steer the AI assistant toward Trysil's real API and conventions. The source of truth is always the Trysil source code.
