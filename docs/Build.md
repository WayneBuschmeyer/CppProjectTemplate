# Build guide

## Canonical model

CMake targets are authoritative. Visual Studio, local command-line builds, and
CI all consume the same targets and presets.

Generated IDE projects are never committed.

## Visual Studio

Open the repository folder directly.

`CMakePresets.json` uses Ninja with external architecture/toolset information so
Visual Studio can establish the correct x64 compiler environment before CMake is
invoked.

The preset file deliberately remains schema 9 because Visual Studio parses the
file independently of the standalone CMake executable.

## Windows command line

From a normal terminal:

```powershell
scripts\Build.cmd msvc-debug
scripts\Build.cmd msvc-relwithdebinfo
scripts\Build.cmd msvc-release
scripts\Build.cmd clangcl-relwithdebinfo
```

`Build.cmd` is only a thin wrapper around `Build.ps1`.

The PowerShell helper:

1. uses Visual Studio 2026's bundled CMake 4.3+ on Windows;
2. locates Visual Studio 2026 with `vswhere`;
3. enters the supported Developer PowerShell environment;
4. verifies Ninja is available;
5. runs the selected CMake workflow preset.

## Standard build configurations

`Debug`, `RelWithDebInfo`, and `Release` remain distinct.

`RelWithDebInfo` is the normal optimized investigation/profiling configuration
because it retains symbols. `Release` is the final optimized configuration.

## Compiler warnings

Warnings are target-scoped and deliberately conservative enough to work across
the supported compiler families.

Warnings-as-errors applies only to project-owned targets. Third-party
dependencies do not inherit project warning policy.

## Sanitizers

Use:

```text
msvc-debug-asan
linux-clang-sanitized
```

The Linux sanitized configuration enables both AddressSanitizer and
UndefinedBehaviorSanitizer.

MSVC AddressSanitizer disables incompatible runtime checks in its dedicated
preset and disables incremental linking on final-link targets.

## Static analysis

Required CI policy:

```text
linux-clang-tidy
```

Optional configurations:

```text
msvc-clang-tidy
msvc-native-analysis
```

### Coverage

```text
linux-clang-coverage
```

Requested analyzers fail configuration if the required executable is missing.
They never silently skip analysis.

## IPO/LTO

Optimized builds probe IPO/LTO support with CMake's
`CheckIPOSupported`. When available, IPO applies only to project-owned targets.

## Public-header verification

Shared developer presets enable `CMAKE_VERIFY_INTERFACE_HEADER_SETS`.

The normal build depends on CMake's generated header-verification target, so a
public header must compile independently instead of depending on include order.

## CMake version policy

The project intentionally requires CMake 4.3, matching the supported Visual
Studio 2026 integration instead of requiring a separate newer CMake for an
optional diagnostic feature.

Install destinations in the project are explicitly relative, and preset/cache
variables are kept small and reviewed directly. If a future project requirement
needs a newer CMake feature, raise the minimum version at that point and update
the compatibility contract with it.

## Installation

The library installs a namespaced CMake package:

```cmake
find_package(ProjectName CONFIG REQUIRED)

target_link_libraries(
    Consumer
    PRIVATE
        ProjectName::ProjectName
)
```

CI installs to a clean prefix and builds a separate consumer project to verify
the exported target.

## Generated output

All normal generated state belongs below:

```text
out/
  build/<preset>/
  install/<preset>/
```
