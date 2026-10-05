# Contributing

## Workflow

Create a focused branch from current `main`, make one coherent change, run the
relevant local checks, push the branch, and open a pull request.

`main` is intended to remain a known-good baseline.

## C++ style

Run Clang-Format using the repository `.clang-format`. CI uses
`clang-format-22`.

Naming is enforced by Clang-Tidy where practical:

- types: PascalCase;
- functions/methods: camelCase;
- variables/parameters/members: camelCase;
- constants and `constexpr` values, including locals: UPPER_SNAKE_CASE.

Prefer `and`, `or`, and `not` over symbolic logical operators in project code.

## CMake

Prefer target-scoped usage requirements over directory-wide compiler flags.
Project-development warnings, analyzers, sanitizers, and hardening should remain
PRIVATE unless consumers genuinely need the requirement.

Do not raise a minimum tool version merely because a newer version exists.
Raise it when the project intentionally uses a capability that requires it.

## Tests

Behavior changes should normally include a test. Prefer compile-time
`static_assert` tests when the behavior is genuinely compile-time; use
GoogleTest for runtime behavior.
