# Contributing to Trysil

Thank you for your interest in contributing to Trysil!

## Ways to Contribute

- **Report bugs** -- open an [issue](https://github.com/davidlastrucci/Trysil/issues) with steps to reproduce
- **Suggest features** -- open an issue describing the use case
- **Share your project** -- tell us how you use Trysil in the [Show and tell](https://github.com/davidlastrucci/Trysil/issues/9) issue
- **Translate** -- add a new language file (see [Demos/Languages](Demos/Languages/))
- **Improve documentation** -- fix typos, add examples, clarify explanations
- **Submit code** -- bug fixes and enhancements via pull request

## Submitting a Pull Request

1. Fork the repository and create a branch from `master`.
2. Make your changes following the code style below.
3. Test with at least one database driver (SQLite is the easiest).
4. Open a pull request with a clear description of what changed and why.

## Code Style

- **Naming**: classes `TT*`, exceptions `ET*`, units `Trysil.*`
- **Fields**: `strict private`, accessed via properties
- **Strings**: use `Format()`, not concatenation
- **Collections**: `TTObjectList<T>` with `OwnsObjects = True` for owned objects
- **No default parameters**: use separate overloaded methods
- **Copyright header**: all source files must include the Trysil copyright header

## Building

Build the packages for your Delphi version from the command line:

```
Packages\Build370.bat
```

Or open `Packages/<ver>/Trysil.groupproj` in the IDE and use **Build All**.

## Questions?

Open an issue or write to [david.lastrucci@gmail.com](mailto:david.lastrucci@gmail.com).
