# Compatibility contract

This repository targets a known modern environment rather than the lowest
common denominator across old C++ toolchains.

## Supported baseline

| Layer | Contract |
| --- | --- |
| Language | C++23 |
| Build system | CMake 4.3+ |
| Preset schema | 9 |
| Windows IDE | Visual Studio 2026 |
| Windows generator | Ninja |
| Windows compilers | MSVC and clang-cl |
| Linux compilers | Clang and GCC |
| macOS compiler | Apple Clang |
| Formatter policy | Clang-Format 22 |
| Required static analysis | Clang-Tidy 22 |
| Unit tests | GoogleTest 1.18.0 SHA-256-pinned archive |

## Why CMake 4.3?

Visual Studio 2026 is the primary Windows IDE, and its supported CMake
integration provides the baseline the project should work with out of the box.
The template therefore requires CMake 4.3 rather than raising the minimum for a
feature that is not necessary to the architecture.

A future minimum-version increase should happen only when the project actually
uses a capability that requires it. The installed package version file uses
CMake's long-established `SameMajorVersion` compatibility mode for the same
reason; the newer `SemanticVersion` mode is not part of the CMake 4.3 baseline.

## Why preset schema 9?

CMake and Visual Studio are separate consumers of `CMakePresets.json`. Visual
Studio reads and evaluates the preset file itself, so the template must respect
the IDE's schema compatibility ceiling rather than looking only at what a newer
standalone CMake can parse.

Schema 9 already supports the configure, build, test, workflow, inheritance,
condition, and environment features used by this project. It does not support
the `$comment` field, which begins with preset schema 10. Newer diagnostic
fields such as `errors.unusedCli` and `installAbsoluteDestination` also require
a newer preset schema, so they do not belong in this shared file. Keep that
rationale in normal documentation instead of raising the schema only for JSON
comments or optional diagnostics.

`scripts/ValidatePresets.cmake` makes schema 9 an executable project contract so
a future edit cannot silently raise it.

The shared preset file deliberately does not set `cmakeExecutable`. Visual
Studio should choose its supported CMake executable instead of interpreting a
relative executable name as a path inside the source tree.

## Windows environment

Visual Studio establishes the MSVC and Windows SDK environment when the folder
is opened in the IDE.

`scripts/Build.ps1` uses Visual Studio's supported Developer PowerShell bootstrap
when invoked from an ordinary terminal. It prefers Visual Studio's bundled
CMake and Ninja so the IDE and command-line workflows stay aligned.

`scripts/InitializeProject.ps1` uses the same bundled CMake when available and
falls back to a compatible `cmake` on `PATH`.

## Runner labels

CI uses explicit runner labels rather than moving `*-latest` aliases:

```text
windows-2025-vs2026
ubuntu-26.04
macos-26
```

The repository still expects runner images to evolve within those OS labels.
Pinned formatter/analyzer major versions prevent normal image churn from
silently changing formatting or static-analysis policy.

## Version upgrades

When upgrading a tool or format:

1. identify every program that consumes the file or feature;
2. verify both the minimum capability and any consumer compatibility ceiling;
3. prefer an already-supported toolchain capability over adding a new minimum;
4. update local development, CI, and documentation together;
5. validate on Visual Studio, command line, and GitHub Actions before release.
