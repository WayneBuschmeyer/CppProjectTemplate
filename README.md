# C++ Project Template

A deliberately opinionated C++23 project template for modern coursework,
personal projects, and reusable libraries.

The template standardizes repetitive engineering work so a new project can
begin with source code instead of build-system setup.

## Baseline

- C++23 public language contract
- CMake 4.3 or newer
- CMake Presets schema 9 for Visual Studio 2026 compatibility
- Ninja as the normal generator
- Visual Studio 2026 as the primary Windows IDE
- MSVC and clang-cl validation on Windows
- Clang and GCC validation on Linux
- Apple Clang validation on macOS
- GoogleTest 1.18.0 pinned by SHA-256
- AddressSanitizer and UndefinedBehaviorSanitizer configurations
- Clang-Tidy 22 and Clang-Format 22 in CI
- install/export rules with an independent `find_package()` consumer
- GitHub Actions, CodeQL, Dependabot, and SHA-pinned Actions

The Windows baseline intentionally matches the CMake integration bundled with
Visual Studio 2026. The project does not require a separate CMake installation
just to use the supported IDE workflow.

## First use

Create a new repository from this template, then initialize it once:

```powershell
scripts\InitializeProject.cmd ExactMath "Exact rational arithmetic and linear algebra"
```

The project name must use PascalCase.

Initialization replaces the template placeholders, renames the public include
directory/header/source file, gives private CMake helpers a project-specific
prefix, and removes the template-maintenance validation workflow. The generated
project keeps its normal build/test and CodeQL workflows. Running the initializer
a second time is intentionally rejected.

## Windows development

Open the repository folder directly in Visual Studio. The project uses
`CMakePresets.json`; generated `.sln` and `.vcxproj` files are not committed.

Visual Studio chooses its own supported CMake executable. The shared presets do
not override `cmakeExecutable`, because that field is IDE-specific and a relative
value can be interpreted as a path inside the repository.

For a normal command-line build from PowerShell or Command Prompt:

```powershell
scripts\Build.cmd msvc-debug
```

The Windows helper prefers the CMake and Ninja bundled with the detected Visual
Studio 2026 installation, so command-line builds exercise the same supported
CMake integration as the IDE.

Other useful workflows include:

```text
msvc-debug-asan
msvc-relwithdebinfo
msvc-release
clangcl-debug
clangcl-relwithdebinfo
```

## Linux and macOS

CMake 4.3+ and Ninja must be available on `PATH`. Use workflow presets directly:

```bash
cmake --workflow --preset linux-clang-sanitized
cmake --workflow --preset linux-gcc-relwithdebinfo
cmake --workflow --preset macos-clang-debug
```

## Style

Formatting intentionally stays close to an official tool default:

```yaml
BasedOnStyle: Microsoft
Standard: Latest
```

The formatter, not hand-written spacing rules, is the source of truth for
cosmetic layout.

Naming policy remains explicit because names communicate design:

- types use PascalCase;
- functions, variables, parameters, and members use camelCase;
- constants and `constexpr` values use UPPER_SNAKE_CASE, including locals;
- standard-library names stay qualified with `std::`;
- keyword logical operators (`and`, `or`, `not`) are preferred in project code.

## Repository structure

```text
app/                 starter executable
cmake/               reusable project policy
docs/                build and compatibility documentation
include/ProjectName/ public API before initialization
scripts/             initialization, validation, and Windows build helpers
src/                 library implementation
tests/               unit tests and independent package consumer
```

See `docs/Build.md` and `docs/Compatibility.md` for the detailed engineering
contract.
