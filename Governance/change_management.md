# Change management

## Workflow

1. Create a branch from `main` (`feature/<short-name>` or `fix/<short-name>`).
2. Make the change and run `make build` on the full data.
3. If a metric formula changes, update `metric_definitions.md` and add an entry to `change_log.md` in the same branch.
4. Open a pull request. The template asks for the impact on reported numbers.
5. **dbt CI** (`.github/workflows/dbt_ci.yml`) runs `dbt build --target ci` on the committed sample: all models plus all 90 tests.
6. Review the diff (on a team, a code owner from `.github/CODEOWNERS` approves).
7. Merge only when CI is green.

## Branch protection on `main` (enabled)

Settings → Branches → rule for `main`:

- **Require a pull request before merging**: nobody pushes to `main` directly
- **Require status checks to pass: `dbt-build`**: the CI job must be green

A failing error-severity dbt test fails the `dbt-build` check, and GitHub blocks the merge.

Approvals are not required because this is a single-maintainer repository (GitHub does not let authors approve their own pull requests). On a team, also turn on **Require approvals (1)** and **Require review from Code Owners**, which uses `.github/CODEOWNERS`.

## Lineage

`make docs` regenerates `Docs/dbt_docs/index.html`, a static dbt docs site with the full lineage graph (raw files → staging → intermediate → marts). Regenerate it in any pull request that adds or renames a model.
