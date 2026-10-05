# Template setup

Use this file when creating a project from the GitHub template repository.

## 1. Initialize once

On Windows:

```powershell
scripts\InitializeProject.cmd MyProject "Short human-readable description"
```

Portable CMake form:

```bash
cmake \
  -DPROJECT_NAME=MyProject \
  -DPROJECT_DESCRIPTION="Short human-readable description" \
  -P scripts/InitializeProject.cmake
```

`PROJECT_NAME` must use PascalCase and contain only letters and numbers.

## 2. Review the generated project

Check at least:

- `project()` name, description, and version;
- public header/API names;
- starter application;
- tests;
- README;
- package namespace;
- project option prefix.

## 3. Build

Windows:

```powershell
scripts\Build.cmd msvc-debug
```

Linux/macOS:

```bash
cmake --workflow --preset <workflow-name>
```

## 4. Replace the starter API

The initial `getName()` function exists only to prove that:

- the library compiles and links;
- the application consumes the public target;
- tests consume the same public API;
- installation exports a usable package.

Delete or replace it when the real project begins.
