# Settings

**Trysil > Settings** sets the defaults of the Expert. They are saved for your Windows user, in the registry under `HKEY_CURRENT_USER\SOFTWARE\Trysil\Expert`, and apply to every project.

![Settings](images/settings.png)

The tree on the left chooses the page: **Trysil**, **Models**, **Rules** or **Controllers**.

| Page | Field | Default | Meaning |
|---|---|---|---|
| Trysil | Directory | `__trysil` | Folder, relative to the project, where the entity model is saved |
| Models | Directory | `Model` | Default folder of the generated entity units |
| Models | Unit filenames | `{ProjectName}.Model.{EntityName}` | Default pattern of the unit names |
| Rules | Directory | `Rules` | Default folder of the generated rules units |
| Rules | Unit filenames | `{ProjectName}.Rule.{EntityName}` | Default pattern of the rules unit names |
| Controllers | Directory | `Controllers` | Default folder of the generated controller units |
| Controllers | Unit filenames | `{ProjectName}.Controller.{EntityName}` | Default pattern of the controller unit names |

## Defaults and project settings

The directories and unit filenames of **Models**, **Rules** and **Controllers** are only the starting values. The first time you confirm [Generate entity model](generate-model.md) in a project, the values in that dialog are saved with the project, in `__trysil\__settings\settings.json`, and from then on the project uses its own values: changing the settings later does not affect it. A project saved before rules and controllers had their own settings takes them from here until its next generation.

**Trysil > Directory** is different: it is read every time, for every project. If you change it, the Expert looks for the model of all your projects in the new folder, so set it once, before you start, and leave it.
