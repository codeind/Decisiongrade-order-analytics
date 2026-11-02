# Change management

## Workflow

1. Create a branch from `main` (`feature/<short-name>` or `fix/<short-name>`).
2. Make the change and run `make build` on the full data.
3. If a metric formula changes, update `metric_definitions.md` and add an entry to `change_log.md` in the same branch.
4. Open a pull request. The template asks for the impact on reported numbers.
5. **dbt CI** (`.github/workflows/dbt_ci.yml`) runs `dbt build --target ci` on the committed sample: all models plus all 90 tests.
6. A code owner reviews (`.github/CODEOWNERS` covers metric marts, tests and this folder).
7. Merge only when CI is green and the review is approved.

## Branch protection settings (GitHub → Settings → Branches → Add rule for `main`)

- Require a pull request before merging
- Require approvals: 1
- Require review from Code Owners
- Require status checks to pass: `dbt-build`
- Do not allow bypassing the above settings

With these on, a failing error-severity test makes the `dbt-build` check fail and GitHub blocks the merge.

## Lineage

`make docs` regenerates `Docs/dbt_docs/index.html`, a static dbt docs site with the full lineage graph (raw files → staging → intermediate → marts). Regenerate it in any pull request that adds or renames a model.
