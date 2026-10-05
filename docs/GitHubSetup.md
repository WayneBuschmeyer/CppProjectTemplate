# GitHub repository policy

## Actions

Workflows use the minimum practical `GITHUB_TOKEN` permissions and pin external
Actions to full commit SHAs.

Example:

```yaml
uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
```

The version comment is for people; the SHA is the immutable execution reference.

Dependabot is configured to propose GitHub Actions updates weekly.

## Recommended main-branch rules

Protect `main` with:

- pull requests required;
- zero artificial approval requirement for a solo repository;
- required status checks;
- branch must be current before merge;
- conversations resolved;
- linear history;
- squash merge only;
- force pushes blocked;
- deletion blocked.

## Recommended repository settings

- template repository enabled;
- Issues enabled;
- Wiki and Projects disabled unless deliberately used;
- delete merged branches automatically;
- read-only Actions token permissions by default;
- Actions may not approve pull requests;
- secret scanning/push protection when available;
- Dependabot security updates;
- private vulnerability reporting;
- immutable releases.

## Release model

The first public release is `v1.0.0`.

Internal development iterations before public release are not part of the
public version history.

Use semantic versioning for the template itself:

```text
v1.0.1  compatible bug fix
v1.1.0  compatible new capability
v2.0.0  meaningful breaking template change
```
